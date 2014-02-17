module Webhelp
module Html

# Html generation helpers for images.
class Image

  CssRulespacePrefx = "_#{AutoLoader.class_name_to_file_name self.class.name}_"
  module CssRulespace
    Image = CssRulespacePrefx + 'image'
  end

  CommonCssForImage = %w[
    background-repeat   no-repeat
    background-position top\ center
    display             inline-block
  ]

  # Return a CSS array with all rules
  # for giving a block an image background.
  # @return [Array(String, String)]
  #     [ [prop, value], ... ]
  def self.css_for_image url, width, height
    %w[
      background-image     url('#{url}')
      width                #{width}px
      height               #{height}px
    ].each_slice(2).to_a
  end

  # Return a CSS array with all rules
  # for giving a block an image background,
  # on mouse hover-over.
  # @return [Array(String, String)]
  #     [ [prop, value], ... ]
  def self.css_for_image_hover url
    %w[
      background-image     url('#{url}')
    ].each_slice(2).to_a
  end

  # Return the hover id for an image-background
  # element, based on the given selector prefix or
  # the default of #id:hover.
  # @param prefix [String, Symbol, nil] 
  #     a full css selector to be placed before the
  #     element id
  # @param id [String, Symbol] the element id,
  #     including #
  def self._get_hover_id prefix, id
    if prefix
      then :"#{prefix} #{id}"
      else :"#{id}:hover"
    end
  end

  # @param gen2 [Gen2]
  # @param hamler [#haml, #html_escape]
  def initialize gen2, hamler
    @gen2     = gen2
    @hamler   = hamler
  end

  # Generates an html element with the appropriate class
  # and id so that it behaves like an image (has an
  # image background).
  #
  # This operation requires the gen2 functionality
  # (two-stage generation), and specifically the
  # morecss facility, in order to append generated css
  # information.
  #
  # @param id [Symbol] the id to give to the element
  #     (without #)
  # @param width [Fixnum] image width in pixels
  # @param height [Fixnum] image height in pixels
  # @param url [String] the image url
  # @param with_hover [Boolean] make the element change
  #     image background on hover
  # @param hover_selector_prefix [Symbol, nil] the hover
  #     condition css selector (prepended to id)
  # @return [String] an html piece of code with the
  #     generated element
  def img(
    id, url, width, height,
    with_hover = false, hover_selector_prefix = nil,
    attrs = {}
  )
    id = :"##{id or @hamler.html_escape img_id_manager[name]}"
    # add common rule for all image-background elements
    @gen2.morecss :".#{CssRulespace::Image}", CommonCssForImage
    # add css for this specific element
    @gen2.morecss id, Image.css_for_image(url, width, height)
    # add more-css for hovering
    if with_hover then
      hover_id  = Image._get_hover_id hover_selector_prefix, id
      hover_url = rcmapper.translate :"#{name}_hover"
      @gen2.morecss hover_id, Image.css_for_image_hover(hover_url)
    end
    # add sass extra mixins
  # if extra_mixins then
  #   for extra_mixin in Array extra_mixins do
  #     get_morecss[imgid] << "@include #{extra_mixin}"
  #   end
  # end
    haml_code = "#{imgid}.image{attrs}"
    @hamler.haml haml_code, locals: {attrs: attrs}
  end

end#module Image

end#module Html
end#module Webhelp
