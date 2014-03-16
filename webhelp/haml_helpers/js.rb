module Webhelp
module HamlHelpers

module Js
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ config jsimportcache ]

  # Basename of the opal source in the public dir
  Opal      = 'opal'
  # Basename of the j-query source in the public dir
  JQuery    = 'jquery'

  def __js_import urls
    js_srcs = urls.map do |url|
                escaped_url = url.gsub '|', '\|'
                absolute_url = "/#{escaped_url}"
                "%script{src: %Q|#{to absolute_url}|}"
              end.
              join "\n"
    literal_lines = (yield.each_line.map(&'  '.method(:+)).join if block_given?)
    literal_lines = nil if literal_lines && literal_lines.gsub(/\s+/, '').empty?
    haml_code = "#{js_srcs}\n"
    haml_code += ":javascript\n#{literal_lines}\n" if literal_lines
    haml haml_code
  end

  module Environments

    module Development

      # @param ids [:Opal, :JQuery]
      #
      def js_import *ids, &block
        __js_import ids.map { |id| "#{Js.const_get id}.js" }, &block
      end

    end#module Development

    module Default

      # @param ids [:Opal, :JQuery]
      #
      def js_import *ids
        __js_import ids.map { |id| "#{Js.const_get id}-min.js" } do
          if block_given? and custom = yield then
            jsimportcache[custom] ||= Webhelp::Minify::Javascript.minify custom
          end
        end
      end

    end#module Default

  end#module Environments

end#module Js

end#module HamlHelpers
end#module Webhelp
