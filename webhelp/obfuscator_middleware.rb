require 'sinatra/base'

module Webhelp

class ObfuscatorMiddleware < Sinatra::Base

  # Separates a string into non-script and script sections.
  # For example
  #   <html>
  #     <head>
  #       <title>T</title>
  #       <script>var a;</script>
  #     </head>
  #     <body>
  #       <script>var b;</script>
  #     </body>
  #   </html>
  # should be split to
  #   [
  #     [
  #       "<html>\n  <head>\n    <title>T</title>\n    ",
  #       "\n  </head>\n  <body>\n    ",
  #       "\n  </body>\n</html>"
  #     ],
  #     [
  #       "<script>var a;</script>",
  #       "<script>var b;</script>"
  #     ]
  #   ]
  def self.separate_tags_sections tags_names, source
    tags_regex        = /<(#{tags_names.join '|'})[^>]*>/
    opening_regex     = /(?=#{tags_names.map do |t| "<#{t}[^>]*>" end.join '|'})/
    name_regex        = /^#{tags_regex}/
    tag_sections      = []
    non_tag_sections  = []

    rest = source
    until rest.nil? or rest.empty? do
      non_tag_sec, rest = rest.split opening_regex, 2
      non_tag_sections << non_tag_sec if non_tag_sec
      if rest then
        tag_name      = name_regex.match(rest)[1]
        closing_regex = %r,(?<=</#{tag_name}>),
        tag_sec, rest = rest.split closing_regex, 2
        tag_sections << tag_sec
      end
    end

    [non_tag_sections, tag_sections]
  end

  # @param processed_sections [Array<String>]
  # @param untouched_sections [Array<String>]
  # @return [String]
  #     clean[0] + tag[0] + clean[1] + ...
  def self.join_sections processed_sections, untouched_sections
    raise ArgumentError.new("not(processed_sections.length - untouched_sections.length <= 1)") \
        unless processed_sections.length - untouched_sections.length <= 1
    result = ''
    processed_sections.zip untouched_sections do |clean, script|
      result << clean
      result << script if script
    end
    result
  end

  class ObfuscationInvalidityError < Exception; end
  # Ensures that de-obfuscating an obfuscated source results
  # back to the original source.
  # @param original_source [String] the original source
  # @param obfuscated_sections [Array<String>] the obfuscated
  #     sections
  # @param clean_sections [Array<String>] sections between the
  #     obfuscated sections, which did not undergo obfuscation
  # @param deobfuscate [#call([String])] the
  #     deobfuscation-on-string operation
  # @param join [#call(de-obfuscated_sections, clean_sections)]
  #     joins de-obfuscated_sections and clean_sections into a
  #     [String]
  # @return [nil | String] nil when everything is fine, an
  #     html body describing the error else.
  def self.ensure_obfuscation_validity original_source, obfuscated_sections, clean_sections, deobfuscate, join
    deobfuscateds       = obfuscated_sections.map &deobfuscate
    deobfuscated_source = join.call deobfuscateds, clean_sections
    unless deobfuscated_source == original_source then
      require 'diffy'
      diff = Diffy::Diff.new(original_source, deobfuscated_source)
      body =  "!!!\n"                               +
              "%html\n"                             +
              "  %head\n"                           +
              "    %title Obfuscation Error\n"      +
              "    :css\n"                          +
              Diffy::CSS.each_line.map { |line|
              "      #{line}" }.join                +
              "  %body\n"                           +
              "    %h1 Obfuscation Error\n"         +
              "    %p Please check the diff below\n"+
              "    :plain\n"                        +
              diff.to_s(:html).each_line.map { |line|
              "      #{line}" }.join
      Haml::Engine.new(body).render
    end
  end

  def initialize app
    super
    @ob = Webhelp::Obfuscator.new
  end

  def obfuscate_except_for_tags(tags_names:, obfuscate:, deobfuscate:, source:)
    cleans, tags  = ObfuscatorMiddleware.separate_tags_sections tags_names, source
    obfuscateds   = cleans.map &obfuscate
    if error_body = ObfuscatorMiddleware.ensure_obfuscation_validity(
                      source, obfuscateds, tags, deobfuscate, ObfuscatorMiddleware.method(:join_sections))
      then halt 500, error_body
    end
    obfuscated = ObfuscatorMiddleware.join_sections obfuscateds, tags
    obfuscated
  end

  def obfuscate_only_tag(tag_name:, obfuscate:, deobfuscate:, source:)
    cleans, tags  = ObfuscatorMiddleware.separate_tags_sections [tag_name], source
    obfuscateds   = tags.map &obfuscate
    if error_body = ObfuscatorMiddleware.ensure_obfuscation_validity(
                      source, obfuscateds, cleans, deobfuscate,
                      lambda do |deobs, cleans| ObfuscatorMiddleware.join_sections cleans, deobs end)
      then halt 500, error_body
    end
    obfuscated = ObfuscatorMiddleware.join_sections cleans, obfuscateds
    obfuscated
  end

  def obfuscate
    ob_html =
    obfuscate_except_for_tags(tags_names:   [:style, :script]             ,
                              obfuscate:    @ob.method(:obfuscate_html    ),
                              deobfuscate:  @ob.method(:deobfuscate_html  ),
                              source:       body.join                     ,
                              )
    ob_html_css =
    obfuscate_only_tag(       tag_name:     :style                        ,
                              obfuscate:    @ob.method(:obfuscate_css     ),
                              deobfuscate:  @ob.method(:deobfuscate_css   ),
                              source:       ob_html                       ,
                              )
    ob_html_css_js =
    obfuscate_only_tag(       tag_name:     :script                       ,
                              obfuscate:    @ob.method(:obfuscate_js      ),
                              deobfuscate:  @ob.method(:deobfuscate_js    ),
                              source:       ob_html_css                   ,
                              )
    body ob_html_css_js
  end

  after do
    case response.content_type
      when %r{^text/html} then obfuscate
    end
  end#after

end#class ObfuscatorMiddleware

end#module Webhelp
