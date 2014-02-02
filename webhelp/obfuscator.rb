module Webhelp

#
# This obfuscator expects everything to be minified.
#
class Obfuscator

  CssNameCatcher  = /([#\.])(\w+)([{\s>~:,\[])/
  HexColorCatcher = /^\h{6}|\h{3}$/
  HtmlNameCatcher = /(class|id|for)(\s*=\s*["']?)(\w+)(["']?)/

  OpReg   = Webhelp::IdManager.public_instance_method :[]
  OpGet   = Webhelp::IdManager.public_instance_method :get
  OpRGet  = Webhelp::IdManager.public_instance_method :reverse_get
  private_constant *%i{ OpReg OpGet OpRGet }

  def initialize
    @ids, @classes = Array.new 2 do Webhelp::IdManager.new end
  end

  # Substitute all detected class and ID names
  # in a CSS string with their obfuscated mappings.
  # @return [String] the obfuscated string
  def obfuscate_css str
    css_obfuscation_operation OpGet, str
  end

  def deobfuscate_css str
    css_obfuscation_operation OpRGet, str
  end

  # Detect class and ID names from an HTML file and
  # obfuscate them.
  # @return [String] the obfuscated string
  def obfuscate_html str
    html_obfuscation_operation OpReg, str
  end

  def deobfuscate_html str
    html_obfuscation_operation OpRGet, str
  end

  def each_id_mapping &block
    @ids.each &block
  end

  def each_class_mapping &block
    @classes.each &block
  end


  private
  def css_obfuscation_operation operation, str
    str.gsub CssNameCatcher do
      begin
        whole         = $~[0]
        discriminator = $~[1]
        id            = $~[2]
        next_char     = $~[3]
        manager       = case discriminator
                          when '.' then @classes
                          when '#' then @ids
                          else raise "How? #{discriminator.inspect}"
                        end
        if id =~ HexColorCatcher # caught a hex color
          then whole
          else "#{discriminator}#{operation.bind(manager).call id}#{next_char}"
        end
      rescue => e
        raise "Error for #{discriminator}#{id}: #{e}"
      end
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
        mapping       = operation.bind(manager).call id
        "#{$~[1]}#{$~[2]}#{mapping}#{$~[4]}"
      rescue => e
        raise "Error for #{discriminator}#{id}: #{e}"
      end
    end
  end


end#class Obfuscator

end#module Webhelp
