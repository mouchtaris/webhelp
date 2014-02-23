module Webhelp
module HamlHelpers

module Rc
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper ]

  module Environments

    module Production

      # Translate _id_ to _local_id_.
      #
      def font_rc id
        original = URI rcmapper.translate id
        "#{Digest::SHA512.new.hexdigest original.to_s}#{File.extname original.path}"
      end

    end#module Production

    module Default

      def font_rc id
        rcmapper.translate id
      end

    end#module Default

  end#module Environments


end#module Rc

end#module HamlHelpers
end#module Webhelp
