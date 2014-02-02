module Webhelp

module HtmlHelpers

  def cssimg name
    url       = get_rcmapper.translate name
    width     = img_width name
    height    = img_height name
    [
      "background-image: url('#{url}')"  ,
      "background-repeat: no-repeat"     ,
      "background-position: top center"  ,
      "width: #{width}px"                ,
      "height: #{height}px"              ,
    ]
  end

  def cssimghover name, hover_selector_prefix: nil
    url_hover = get_rcmapper.translate :"#{name}_hover"
    [
      "background-image: url('#{url_hover}')"
    ]
  end

  def img name, attrs = {}, hover_selector_prefix: nil, extra_mixins: nil
    imgid                     = :"##{html_escape get_imgidmanager[name]}"
    imghoverid                = if hover_selector_prefix
                                  then :"#{hover_selector_prefix} #{imgid}"
                                  else :"#{imgid}:hover"
                                end
    get_morecss[imgid]      ||= cssimg name
    get_morecss[imghoverid] ||= cssimghover name

    if extra_mixins then
      for extra_mixin in Array extra_mixins do
        get_morecss[imgid] << "@include #{extra_mixin}"
      end
    end

    haml_code = "#{imgid}.image{attrs}"
    haml haml_code, locals: {attrs: attrs}
  end

end

end