module Webhelp
module Html

# Html generation helpers for images.
class Image

  def self.make_assoc_css whitespace_separated_array
    whitespace_separated_array.each_slice(2).to_a
  end

  CssRulespacePrefx = "_#{AutoLoader.class_name_to_file_name name}_"
  module CssRulespace
    Image = CssRulespacePrefx + 'image'
  end

  CommonCssForImage = make_assoc_css(%w[
    background-repeat   no-repeat
    background-position top\ center
    display             inline-block
  ]).deep_freeze

  def self._common_css_for_image_class url, width, height
    raise ArgumentError unless url and width and height
    make_assoc_css %W[
      background-image  url('#{url}')
      width             #{width}px
      height            #{height}px
    ]
  end

  def self._specific_css_for_image url, position, offset_x, offset_y
    css = []
    css << %W[ background-image  url('#{url}') ] if url
    if position then
      css << %W[ background-position #{position} ]
    elsif offset_x or offset_y then
      bgpos = "left #{offset_x}px" if offset_x
      bgpos += " top #{offset_y}px" if offset_y
      css << %W[ background-position #{bgpos} ]
    end
    if css.empty? then nil else css end
  end

  # Return a CSS array with all rules
  # for giving a block an image background.
  # @return [{specific: AssocCss, common: {selector: String, rules; AssocCss}}]
  def self.css_for_image url, width, height, position, offset_x, offset_y
    # if width or height is given THEN all of url, width, height must be given
    unless (not(width or height) or (url and width and height))
      raise ArgumentError.new "(width or height) ===> (url and width and height) #{
        PP.pp [url, width, height], ''}"
    end

    commons_css = nil
    commons_key = nil
    if url and width and height then
      commons_key = :".sprite_commons_#{Digest::SHA512.new.hexdigest "#{Digest::SHA512.new.hexdigest url}_#{width}x#{height}"}"
      commons_css = _common_css_for_image_class url, width, height
    end

    specific_url = if commons_css then nil else url end
    assoc_css = _specific_css_for_image specific_url, position, offset_x, offset_y

    {}.tap do |result|
      result[:specific] = assoc_css if assoc_css
      result[:common] =
      {
        selector: commons_key,
        rules:    commons_css,
      } if commons_css
    end
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
  # @param hamler [#haml]
  def initialize gen2, hamler
    @gen2   = gen2
    @hamler = hamler
  end

  def add_common_css_for_images
    @gen2.morecss :".#{CssRulespace::Image}", CommonCssForImage
  end

  def add_more_css selector_id, css_for_image
    specific = css_for_image[:specific]
    @gen2.morecss selector_id, specific if specific
    if common = css_for_image[:common] then
      @gen2.morecss common[:selector], common[:rules]
      common[:selector]
    end
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
  # @param position [String?] image background-position
  #     css property (defaults to top center)
  # @param with_hover_url [String] make the element change
  #     image background on hover, using the image at
  #     _with_hover_url_
  # @param hover_selector_prefix [Symbol, nil] the hover
  #     condition css selector (prepended to id)
  # @return [String] an html piece of code with the
  #     generated element
  def img(attrs = {},
    id:, url:, width:, height:, position:, element_name:,
    offset_x: nil, offset_y: nil,
    with_hover_url: nil, hover_selector_prefix: nil,
    hover_width: nil, hover_height: nil,
    hover_offset_x: nil, hover_offset_y: nil
  )
    imgid = :"##{::Haml::Helpers.html_escape id}"
    add_common_css_for_images
    # add css for this specific element
    common_class = add_more_css imgid, Image.css_for_image(url, width, height, position, offset_x, offset_y)
    # add more-css for hovering
    if with_hover_url then
      hover_id  = Image._get_hover_id hover_selector_prefix, imgid
      with_hover_url = nil if with_hover_url == url
      if hover_width and hover_width != width  then raise ArgumentError.new "hover width different from original #{hover_width} != #{width}. Not cool, man" end
      if hover_height and hover_height != height  then raise ArgumentError.new "hover height different from original #{hover_height} != #{height}. Not cool, man" end
      hover_width = nil if hover_width == width
      hover_height = nil if hover_height == height
      add_more_css hover_id,
          Image.css_for_image(with_hover_url, hover_width, hover_height, nil, hover_offset_x, hover_offset_y)
    end
    # add sass extra mixins
  # if extra_mixins then
  #   for extra_mixin in Array extra_mixins do
  #     get_morecss[imgid] << "@include #{extra_mixin}"
  #   end
  # end
    haml_code = "%#{element_name}#{imgid}.#{CssRulespace::Image}#{common_class}{attrs}"
    @hamler.haml haml_code, scope: Struct.new(:attrs).new(attrs)
  end

  # "Generate" an image, either with css or as
  # an actual image file.
  #
  # @param width [Fixnum?]
  # @param height [Fixnum?]
  def generate id, width = nil, height = nil, attrs: {}, text: nil
    imgid = :"##{::Haml::Helpers.html_escape id}"
    add_common_css_for_images
    assoc_css = []
    assoc_css << %W[ width  #{width }px ] if width
    assoc_css << %W[ height #{height}px ] if height
    assoc_css << ['background', 'radial-gradient(ellipse at center, #cb60b3 0%, #ad1283 50%, #de47ac 100%)']
    @gen2.morecss imgid, assoc_css
    haml_code = "#{imgid}.#{CssRulespace::Image}{attrs}"
    haml_code += "\\ #{text}" if text
    @hamler.haml haml_code, scope: Struct.new(:attrs).new(attrs)
  end

end#module Image

end#module Html
end#module Webhelp
