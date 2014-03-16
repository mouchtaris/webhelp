module Webhelp
module HamlHelpers

module Routing

  def uri addr = nil, absolute = false, add_script_name = false
    if absolute or add_script_name then
      URI super
    else
      path = Pathname addr
      URI(if path.absolute? then
            this_path = Pathname request.path_info
            is_directory = this_path.to_s.end_with? '/'
            this_dir = if is_directory then this_path else this_path.dirname end
            path.relative_path_from this_dir
          else
            path
          end.to_s)
    end
  end
  alias url uri
  alias to  url

end#module Routing

end#module HamlHelpers
end#module Webhelp
