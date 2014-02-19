module Webhelp
module HamlHelpers

module Rc
  extend InstanceRequirementsChecker

  InstanceRequirements = %i[ rc_mapper ]

  module Environments

    module Production

      # Translate _id_ to _local_id_.
      #
      def font_rc id
        rc_mapper.translate :"local_#{id}"
      end

    end#module Production

    module Default

      define_method :font_rc, rc_mapper.method(:translate)
      #def font_rc id
      #  rc_mapper.translate id
      #end

    end#module Default

  end#module Environments


end#module Rc

end#module HamlHelpers
end#module Webhelp
