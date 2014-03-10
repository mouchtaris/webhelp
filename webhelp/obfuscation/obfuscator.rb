module Webhelp
module Obfuscation

#
# This obfuscator expects everything to be minified.
#
class Obfuscator

  module Regexps
    CssSelector     = /[\w #.>:~]+/
    JqSelector      = %r,(?<pre>Element\[["']\$\[\]["']\]\s*\((?<q>["']))(?<id>#{CssSelector})(?<after>(\k<q>)\)),
    ConstDefinition = %r{(?<pre>\.cdecl\s*\([$\w]+,\s*(?<q>["'])C_(?<type>class|id)_name_\d{6}(\k<q>),\s*(?<q2>["']))(?<id>\w+)(?<after>(\k<q2>)\s*\))}
    HtmlName        = /(?<discriminator>class|id|for)(?<assign>\s*\=\s*(?<strdelim>["']?))(?<id>[\w ]+)(\k<strdelim>?)/
  end#namespace Regexps

  OpReg   = Webhelp::IdManager.public_instance_method :[]
  OpGet   = Webhelp::IdManager.public_instance_method :get
  OpRGet  = Webhelp::IdManager.public_instance_method :reverse_get
  private_constant :OpReg, :OpGet, :OpRGet

  def initialize
    @ids, @classes = Array.new 2 do Webhelp::IdManager.new end
  end
  attr_reader :ids, :classes

  # Substitute all detected class and ID names
  # in a CSS string with their obfuscated mappings.
  # @return [String] the obfuscated string
  def obfuscate_css str
    build_css_regex
    css_obfuscation_operation OpGet, str
  end

  # Replace obfuscated class and ID names with their
  # original values.
  # @param str [String] an obfuscated css string
  # @return [String] the de-obfuscated css
  def deobfuscate_css str
    build_reverse_css_regex
    result = css_obfuscation_operation OpRGet, str
  end

  # Detect class and ID names from an HTML file and
  # obfuscate them.
  # @return [String] the obfuscated string
  def obfuscate_html str
    html_obfuscation_operation(OpReg, str)
  end

  # Deobfuscate class and ID names with their original
  # values.
  # @param str [String] an obfuscated html string
  # @return [String] the de-obfuscated html
  def deobfuscate_html str
    html_obfuscation_operation OpRGet, str
  end

  # Obfuscate the CSS class and ID selectors found
  # in literal strings in _str_.
  # @param str [String] a plain string
  # @return [String] the obfuscated string
  def obfuscate_js str
    build_css_regex
    js_obfuscation_operation OpGet, str
  end

  # De-obfuscate all CSS class and ID selectors
  # found in literal strings in _str_.
  # @param str [String] an obfuscated string
  # @return [String] the de-obfuscated result
  def deobfuscate_js str
    build_reverse_css_regex
    js_obfuscation_operation OpRGet, str
  end

  def each_id_mapping &block
    @ids.each &block
  end

  def each_class_mapping &block
    @classes.each &block
  end


  private
  def css_obfuscation_operation operation, str
    return str unless @css_regex
    str.gsub @css_regex do
      whole         = $~[0]
      discriminator = whole[0]
      id            = whole[1..-1]
      manager       = case discriminator
                        when '.' then @classes
                        when '#' then @ids
                        else raise "How? #{discriminator.inspect}"
                      end
      "#{discriminator}#{operation.unbound_call manager, id}"
    end
  end

  def js_obfuscation_operation operation, str
    return str unless @css_regex
    str.gsub Regexps::JqSelector do
      pre     = $~[:pre   ]
      after   = $~[:after ]
      id      = $~[:id    ]
      result  = css_obfuscation_operation operation, id
      %Q,#{pre}#{result}#{after},
    end.gsub Regexps::ConstDefinition do
      pre     = $~[:pre   ]
      after   = $~[:after ]
      id      = $~[:id    ]
      type    = $~[:type  ]
      manager = case type
                  when 'class' then @classes
                  when 'id' then @ids
                  else raise "Invaild name-type #{type.inspect}"
                end
      result  = operation.unbound_call manager, id
      %Q.#{pre}#{result}#{after}.
    end
  end

  def html_obfuscation_operation operation, str
    str.gsub Regexps::HtmlName do
      begin
        discriminator = $~[:discriminator]
        ids_str       = $~[:id]
        assign        = $~[:assign]
        strdelim      = $~[:strdelim]
        ids           = ids_str.split(/\s+/)
        manager       = case discriminator.to_s.downcase
                          when 'class' then @classes
                          when 'id', 'for' then @ids
                          else raise "How? #{discriminator.inspect}"
                        end
        mappings      = ids.map do |id|
                          begin
                            operation.unbound_call manager, id
                          rescue => e
                            raise "Error for #{discriminator} #{id.inspect}: #{e}"
                          end
                        end
        "#{discriminator}#{assign}#{mappings.join ' '}#{strdelim}"
      end
    end
  end

  def build_css_regex
    @css_regex =
    if not @ids.empty? or not @classes.empty? then
      %r,(#{
        (
          @ids.each_id.
            map do |id| Regexp.escape "##{id}" end.
            rsort_by(&:length) +
          @classes.each_id.
            map do |name| Regexp.escape ".#{name}" end.
            rsort_by(&:length)
        ).
        join '|'
        })(?!\w),
    end
  end

  def build_reverse_css_regex
    @css_regex =
    if not @ids.empty? or not @classes.empty? then
      %r,(#{
        (
          @ids.each.
            map do |id, mapping| Regexp.escape "##{mapping}" end.
            rsort_by(&:length) +
          @classes.each.
            map do |id, mapping| Regexp.escape ".#{mapping}" end.
            rsort_by(&:length)
        ).
        join '|'
        })(?!\w),
    end
  end

end#class Obfuscator

end#module Obfuscation
end#module Webhelp
