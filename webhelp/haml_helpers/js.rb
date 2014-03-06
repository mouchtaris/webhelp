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
      def js_import *ids
        js_srcs =
            ids.map do |id|
              src = Js.const_get(id).gsub '|', '\|'
              "%script{src: %Q|/#{src}|}"
            end.
            join "\n"
        literal_lines =
            if block_given? then
              yield.
                  each_line.
                  to_a.
                  map(&'  '.method(:+)).
                  join
            end
        haml "#{js_srcs}\n:javascript\n#{literal_lines}"
      end
    end#module Development

    module Test
      def js_import *ids
        source =
            ids.map do |id|
              source_basename = Js.const_get id
              source_pathname = config.public_dir + source_basename
              source_pathname.read
            end.
            join
        source += yield if block_given?
        "<script>#{source}</script>"
      end
    end#module Test

    module Default
      define_method :js_import__test, Test.instance_method(:js_import)
      # @param ids [:Opal, :JQuery]
      #
      def js_import *ids, &block
        js_import__test *ids.map { |id| :"#{id}Min" }, &block
      end
    end#module Default

  end#module Environments

end#module Js

end#module HamlHelpers
end#module Webhelp
