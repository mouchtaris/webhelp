module Webhelp
module HamlHelpers

module Js
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ config ]

  # File name of the opal source in the public dir
  Opal      = 'opal.js'
  # File name of the minified/obfuscated opal source
  # in the public dir
  OpalMin   = 'opal-min.js'
  # File name of the j-query source in the public dir
  JQuery    = 'jquery.js'
  # File name of the minified j-query source in the
  # public dir
  JQueryMin = 'jquery-min.js'

  module Environments

    module Development
      # @param id [:Opal, :JQuery]
      #
      def js_import id
        src = Js.const_get(id).gsub '|', '\|'
        haml "%script{src: %Q|#{src}|}"
      end
    end#module Development

    module Test
      # @param id [:Opal, :JQuery]
      #
      def js_import id
        source_basename = Js.const_get id
        source_pathname = config.public_dir + source_basename
        source          = source_pathname.read
        "<script>#{source}</script>"
      end
    end#module Test

    module Production
      def js_import id
        case id
          when :JQuery then
            url = Webhelp::Vendor::JQuery::Url.to_s.gsub '|', '\\|'
            haml "%script{src: %Q|#{url}|}"
          when :JQueryMin then
            url = Webhelp::Vendor::JQuery::UrlMin.to_s.gsub '|', '\\|'
            haml "%script{src: %Q|#{url}|}"
          when :Opal then
            "<script>#{opalcore}</script>"
          when :OpalMin then
            "<script>#{opalcoremin}</script>"
        end
      end
    end

    module Default
      define_method :js_import__test, Test.instance_method(:js_import)
      def js_import id
        js_import__test :"#{id}Min"
      end
    end#module Default

  end#module Environments

end#module Js

end#module HamlHelpers
end#module Webhelp
