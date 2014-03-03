module Webhelp
module HamlHelpers

module Html
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper imagemetadata imageidmanager htmlimg ]

  def __element rc_id, id, width, height
    [
      (id     or imageidmanager.next!         ),
      (width  or imagemetadata.width? rc_id   ),
      (height or imagemetadata.height? rc_id  ),
    ]
  end

  module Environments

    module Default

      # Produce html code for an image element.
      #
      # @param rc_id [Symbol] the logical name of the image
      #   resource id
      # @param id [Symbol?] the html id of the generated
      #   html element
      def img rc_id, id: nil, width: nil, height: nil, position: nil, attrs: {}
        url = rcmapper.translate rc_id
        element_id, element_width, element_height = __element rc_id, id, width, height
        htmlimg.img attrs, id: element_id, url: url, width: element_width,
                    height: element_height
      end

    end

    module Development

      define_method :__img__default, Environments::Default.instance_method(:img)

      # Same as {Default#img} except that provides a replacement
      # "image" element in case the image rc is not found.
      #
      def img rc_id, id: nil, width: nil, height: nil, position: nil, attrs: {}
        __img__default rc_id, id: id, width: width, height: height, position: nil
      rescue IndexError # rc not found
        element_id, element_width, element_height = __element rc_id, id, width, height
        htmlimg.generate element_id, element_width, element_height, attrs: attrs
      end

    end

  end

end#module Html

end#module HamlHelpers
end#module Webhelp
