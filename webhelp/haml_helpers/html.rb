module Webhelp
module HamlHelpers

module Html
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper imagemetadata imageidmanager htmlimg ]

  # Produce html code for an image element.
  #
  # @param rc_id [Symbol] the logical name of the image
  #   resource id
  # @param id [Symbol?] the html id of the generated
  #   html element
  def img rc_id, id: nil
    url         = rcmapper.translate rc_id
    width       = imagemetadata.width rc_id
    height      = imagemetadata.height rc_id
    element_id  = element_id || imageidmanager.next!
    htmlimg.img element_id, url, width, height
  end

end#module Html

end#module HamlHelpers
end#module Webhelp
