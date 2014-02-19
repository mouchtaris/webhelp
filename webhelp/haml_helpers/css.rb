module Webhelp
module HamlHelpers

#
# A Haml Helper for dealing with generating css.
#
module Css
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ gen2 ]


  # Generate CSS from the extra css store.
  # @return [String] extra css (CSS code)
  def import_extra_scss
    gen2.morecss.map do |selector, rules|
      rules_str = rules.map do |name, value| "#{name}: #{value};" end.join
      "#{selector}{#{rules_str}}"
    end.
    join
  end

  module Environments
    module Development
      # Development version of css_import emits a simple
      # @import url('...'); css rule.
      #
      # This results in more http requests but keeps the html
      # file more clean for inspection.
      #
      # The app is expected to know how to serve _id_.css.
      #
      # @param id [Symbol] css module's id
      #
      def css_import id
        haml  ":sass\n" +
              "  @import url('#{id}.css')"
      end
    end#module Development

    module Default
      # Inline stylesheet for _id_.
      #
      # _id_css.haml_ is expected to be found in the
      # _views_ directory. Essentially this method calls
      #     haml :"#{id}_css"
      # (now even practically).
      #
      # @param id [Symbol]
      #
      def css_import id
        haml :"#{id}_css"
      end
    end#module Default
  end#module Environments

end#module Css

end#module HamlHelpers
end#module Webhelp
