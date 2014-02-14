module Webhelp
using Util::UnboundMethodRefinements

#
# This obfuscator expects everything to be minified.
#
class Obfuscator

  StringCatcher   = /(")[\w\s\d\.#]+\1/
  HexColorCatcher = /^\h{6}|\h{3}$/
  HtmlNameCatcher = /(class|id|for)(\s*=\s*["']?)(\w+)(["']?)/

  OpReg   = Webhelp::IdManager.public_instance_method :[]
  OpGet   = Webhelp::IdManager.public_instance_method :get
  OpRGet  = Webhelp::IdManager.public_instance_method :reverse_get
  private_constant *%i{ OpReg OpGet OpRGet }

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
    str.gsub StringCatcher do |match|
      css_obfuscation_operation operation, match
    end
  end

  def html_obfuscation_operation operation, str
    str.gsub HtmlNameCatcher do
      begin
        discriminator = $~[1]
        id            = $~[3]
        manager       = case discriminator.to_s.downcase
                          when 'class' then @classes
                          when 'id', 'for' then @ids
                          else raise "How? #{discriminator.inspect}"
                        end
        mapping       = operation.unbound_call manager, id
        "#{$~[1]}#{$~[2]}#{mapping}#{$~[4]}"
      rescue => e
        raise "Error for #{discriminator}#{id}: #{e}"
      end
    end
  end

  def build_css_regex
    @css_regex =
    if not @ids.empty? or not @classes.empty? then
      %r,#{
        (
          @ids.each_id.map do |id| Regexp.escape "##{id}" end.to_a +
          @classes.each_id.map do |name| Regexp.escape ".#{name}" end.to_a
        ).
        map do |r| /#{r}/ end.
        join '|'
        },
    end
  end

  def build_reverse_css_regex
    @css_regex =
    if not @ids.empty? or not @classes.empty? then
      %r,#{
        (
          @ids.each.map do |id, mapping|
              Regexp.escape "##{mapping}"
            end.to_a +
          @classes.each.map do |id, mapping|
              Regexp.escape ".#{mapping}"
            end.to_a
        ).
        map do |r| /#{r}(?!\w)/ end.
        join '|'
        },
    end
  end

end#class Obfuscator

end#module Webhelp
