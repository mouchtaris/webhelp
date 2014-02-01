module Webhelp

module HtmlHelpers

  def cssimg name, indent = nil
    url       = get_rcmapper.translate name
    width     = img_width name
    height    = img_height name
    [
      "#{indent}background-image: url('#{url}')"  ,
      "#{indent}background-repeat: no-repeat"     ,
      "#{indent}background-position: top center"  ,
      "#{indent}width: #{width}px"                ,
      "#{indent}height: #{height}px"              ,
    ]
  end

  def cssimghover name, indent = nil
    url_hover = get_rcmapper.translate :"#{name}_hover"
    [
      "background-image: url('#{url_hover}')"
    ]
  end

  def img name, attrs = {}
    imgid                     = html_escape get_imgidmanager[name]
    imghoverid                = :"#{imgid}:hover"
    get_morecss[imgid]       ||= cssimg name
    get_morecss[imghoverid]  ||= cssimghover name
    haml_code                 = "##{imgid}.image{attrs}"

    haml haml_code, locals: {attrs: attrs}
  end

end

end
