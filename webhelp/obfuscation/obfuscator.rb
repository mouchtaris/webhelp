module Webhelp
module Obfuscation

#
# This obfuscator expects everything to be minified.
#
class Obfuscator

  module Regexps
    CssSelector     = /[\w #.>:~]+/
    HtmlName        = /(?<discriminator>class|id|for)(?<assign>\s*\=\s*(?<strdelim>["']?))(?<id>[\w ]+)(\k<strdelim>?)/
    StringLiteral   = /(?<pre>%Q,)(?<id>[^,]+)(?<after>,)/
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

  # Obfuscate all class and id string constants found
  # in an Opal (ruby) script.
  #
  # Only the parts in <obfuscate_class> and <obfuscate_id>
  # are substituted, and only literal strings defined
  # by the %Q,, syntax (commas as delimiters).
  #
  # @param str [String] obfuscation block
  # @param obfuscationType [:class, ;id] obfuscate class
  #     names or ID names
  # @return [String] same piece of code with string
  #     literal values obfuscated
  def obfuscate_opal str, obfuscation_type
    opal_obfuscation_operation obfuscation_type, OpGet, str
  end

  # Deobfuscate all class and id string constants found
  # in an Opal (ruby) script.
  #
  # Only the parts in <obfuscate_class> and <obfuscate_id>
  # are substituted, and only literal strings defined
  # by the %Q,, syntax (commas as delimiters).
  #
  # @param str [String] deobfuscation block
  # @param obfuscationType [:class, ;id] deobfuscate class
  #     names or ID names
  # @return [String] same piece of code with string
  #     literal values deobfuscated
  def deobfuscate_opal str, obfuscation_type
    opal_obfuscation_operation obfuscation_type, OpRGet, str
  end

  def obfuscate_opal_classes str
    obfuscate_opal str, :class
  end

  def obfuscate_opal_ids str
    obfuscate_opal str, :id
  end

  def deobfuscate_opal_classes str
    deobfuscate_opal str, :class
  end

  def deobfuscate_opal_ids str
    deobfuscate_opal str, :id
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

  def opal_obfuscation_operation obfuscation_type, operation, str
    manager = case obfuscation_type
                when :class then @classes
                when :id then @ids
                else raise ArgumentError.new "Invalid obfuscation_type #{obfuscation_type.inspect}"
              end
    str.gsub Regexps::StringLiteral do
      pre   = $~[:pre]
      id    = $~[:id]
      after = $~[:after]
      "#{pre}#{operation.unbound_call manager, id}#{after}"
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
