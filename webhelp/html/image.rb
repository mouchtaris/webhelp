module Webhelp
module Html

# Html generation helpers for images
module Image

  # Return a CSS array with all rules
  # for giving a block an image background.
  # @retun [Array<(String, String)]
  #     [ [prop, value], ... ]
  def css_for_image name
    url     = rcmapper.translate name
    width   = img_width name
    height  = img_height name
    [
      %w[background-image     url('#{url}')   ],
      %w[background-repeat    no-repeat       ],
      %w[background-position  top\ center     ],
      %w[width                #{width}px      ],
      %w[height               #{height}px     ],
    ]
  end

  # Return a CSS array with all rules
  # for giving a block an image background,
  # on mouse hover-over.
  # @retun [Array<(String, String)]
  #     [ [prop, value], ... ]
  def css_for_image_hover name
    url = rcmapper.translate :"#{name}_hover"
    [
      %w[background-image     url('#{url}')   ],
    ]
  end

end#module Image

#module Html
#module Webhelp
