module Webhelp
module Obfuscation

# Bring into scope
ObfuscationInvalidityError

class DocumentObfuscator

  # @return [Array<(String, String)>] [ [non_tag_section, tag_section], ...]
  def self.separate_tags_sections tags_names, source
    tags_regex        = /<(#{tags_names.join '|'})[^>]*>/
    opening_regex     = /(?=#{tags_names.map do |t| "<#{t}[^>]*>" end.join '|'})/
    name_regex        = /^#{tags_regex}/
    make_closing_regex= lambda do |rest| tag_name = name_regex.match(rest)[1]; %r,(?<=</#{tag_name}>), end
    result            = []

    # TODO RUBYBUG: refinements are not detected with enum_for()
    source.sections(opening_regex, make_closing_regex) do |non_tag_sec, tag_sec|
      result << [non_tag_sec, tag_sec]
    end
    result
  end

  # @param sections [Array<(String, String)>]
  # @return [String] section[i][0] + section[i][1]
  def self.join_sections sections
    sections.reduce '' do |result, pair|
      result << pair[0] if pair[0]
      result << pair[1] if pair[1]
      result
    end
  end

  # Ensures that de-obfuscating an obfuscated source results
  # back to the original source.
  # @param original_source [String] the original source
  # @param sections [Array<(String, String)>] pairs of
  #     obfuscated and non-obfuscated sections
  # @param obfuscated_section_index [Fixnum] the index
  #     of the section element which has undergone obfuscation
  # @param deobfuscate [#call([String])] the
  #     deobfuscation-on-string operation
  # @return [nil | String] nil when everything is fine, an
  #     html body describing the error else.
  def self.ensure_obfuscation_validity(original_source,
    sections,
    obfuscated_section_index,
    deobfuscate
  )
    deobfuscated_source = join_sections \
        sections.map { |pair|
          replacement = pair.dup
          replacement[obfuscated_section_index] &&= deobfuscate.call pair[obfuscated_section_index]
          replacement
        }
    unless deobfuscated_source == original_source then
      require 'diffy'
      require 'haml'
      diff = Diffy::Diff.new(original_source, deobfuscated_source)
      body =  "!!!\n"                               +
              "%html\n"                             +
              "  %head\n"                           +
              "    %title Obfuscation Error\n"      +
              "    :css\n"                          +
              Diffy::CSS.each_line.map { |line|
              "      #{line}" }.join                +
              "      body{font-family: monospace}\n"+
              "      .diff del strong {\n"          +
              "         border: 1px solid red;\n"   +
              "         background-color: #FAA;\n"  +
              "       }\n"                          +
              "       .diff ins strong {\n"         +
              "         border: 1px solid green;\n" +
              "         background-color: #AFA;\n"  +
              "       }\n"                          +
              "  %body\n"                           +
              "    %h1 Obfuscation Error\n"         +
              "    %p Please check the diff below\n"+
              diff.to_s(:html).split(/[\n\r]+/).map { |line|
              "    \\#{line}\n" }.join
      Haml::Engine.new(body).render
    end
  end

  def self.obfuscate_except_for_tags(tags_names:, obfuscate:, deobfuscate:, source:)
    sections  =
        DocumentObfuscator.separate_tags_sections(tags_names, source).
        map_nth 0 do |non_tag| non_tag and obfuscate.call non_tag end
    if error_body =
        DocumentObfuscator.ensure_obfuscation_validity(
            source, sections, 0, deobfuscate)
      then
        raise ObfuscationInvalidityError.new "#{error_body}<!--\n#{
            Haml::Helpers.html_escape Hash(tags_names: tags_names).to_yaml}\n-->"
    end
    obfuscated = DocumentObfuscator.join_sections sections
    obfuscated
  end

  def self.obfuscate_only_tag(tag_name:, obfuscate:, deobfuscate:, source:)
    sections  =
        DocumentObfuscator.separate_tags_sections([tag_name], source).
        map_nth 1 do |tag| tag and obfuscate.call tag end
    if error_body =
        DocumentObfuscator.ensure_obfuscation_validity(
            source, sections, 1, deobfuscate)
      then
        raise ObfuscationInvalidityError.new "#{error_body}<!--\n#{
            Haml::Helpers.html_escape Hash(tag_name: tag_name).to_yaml}\n-->"
    end
    obfuscated = DocumentObfuscator.join_sections sections
    obfuscated
  end

  def initialize
    super
    @ob = Webhelp::Obfuscation::Obfuscator.new
  end

  def obfuscate source
    ob_html = DocumentObfuscator.
    obfuscate_except_for_tags(tags_names:   [:style, :script]             ,
                              obfuscate:    @ob.method(:obfuscate_html    ),
                              deobfuscate:  @ob.method(:deobfuscate_html  ),
                              source:       source                        ,
                              )
    ob_html_css = DocumentObfuscator.
    obfuscate_only_tag(       tag_name:     :style                        ,
                              obfuscate:    @ob.method(:obfuscate_css     ),
                              deobfuscate:  @ob.method(:deobfuscate_css   ),
                              source:       ob_html                       ,
                              )
    ob_html_css_js = DocumentObfuscator.
    obfuscate_only_tag(       tag_name:     :script                       ,
                              obfuscate:    @ob.method(:obfuscate_js      ),
                              deobfuscate:  @ob.method(:deobfuscate_js    ),
                              source:       ob_html_css                   ,
                              )
    ob_html_css_js
  end

end#class DocumentObfuscator

end#module Obfuscation
end#module Webhelp
