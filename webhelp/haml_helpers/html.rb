module Webhelp
module HamlHelpers

module Html
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper imagemetadata imageidmanager htmlimg spritemanager ]

  def __rc_id img_id
    spritemanager.rc? img_id or img_id
  end

  def __hover_rc_id img_id
    spritemanager.hover_rc? img_id or :"#{__rc_id img_id}_hover"
  end

  def __element img_id, id, width, height, offset_x, offset_y
    result = [(id or imageidmanager.next!)]
    if spritemanager.sprite? img_id then
      result.concat [
        (width    or   spritemanager.width    img_id  ),
        (height   or   spritemanager.height   img_id  ),
        (offset_x or -(spritemanager.offset_x img_id) ),
        (offset_y or -(spritemanager.offset_y img_id) ),
      ]
    else
      rc_id = __rc_id img_id
      result.concat [
        (width  or imagemetadata.width? rc_id   ),
        (height or imagemetadata.height? rc_id  ),
      ]
    end
    result
  end

  module Environments

    module Default

      # Produce html code for an image element.
      #
      # @param img_id [Symbol] the logical name of the image
      #   id -- could be a sprite or an actual rc id
      # @param id [Symbol?] the html id of the generated
      #   html element
      def img img_id, id: nil, width: nil, height: nil, position: nil, attrs: {},
          with_hover: nil, offset_x: nil, offset_y: nil
        ### TODO make params signature and reuse same element id for identical requests
        rc_id       = __rc_id img_id
        url         = rcmapper.translate rc_id
        eid, ew, eh, eoffx, eoffy = __element img_id, id, width, height, offset_x, offset_y

        hw, hh, hoffx, hoffy = nil
        hover_url = nil
        if (h_img_id = with_hover && :"#{img_id}_hover") then
          hover_rc_id = __hover_rc_id img_id
          hover_url   = rcmapper.translate hover_rc_id
          _, hw, hh, hoffx, hoffy = __element h_img_id, eid, nil, nil, nil, nil
        end
        htmlimg.img attrs, id: eid, url: url, width: ew, height: eh, position: position,
                    with_hover_url: hover_url, offset_x: eoffx, offset_y: eoffy,
                    hover_width: hw, hover_height: hh, hover_offset_x: hoffx,
                    hover_offset_y: hoffy
      end

    end

    module Development

      define_method :__img__default, Environments::Default.instance_method(:img)

      # Same as {Default#img} except that provides a replacement
      # "image" element in case the image rc is not found.
      #
      def img img_id, id: nil, width: nil, height: nil, position: nil, attrs: {},
          with_hover: nil, offset_x: nil, offset_y: nil
        __img__default img_id, id: id, width: width, height: height, position: position,
            with_hover: with_hover, attrs: attrs, offset_y: offset_y, offset_x: offset_x
      rescue IndexError => e # rc not found
        element_id, element_width, element_height = __element img_id, id, width, height, nil, nil
        htmlimg.generate element_id, element_width, element_height, attrs: attrs, text: e
      end

    end

  end

end#module Html

end#module HamlHelpers
end#module Webhelp
