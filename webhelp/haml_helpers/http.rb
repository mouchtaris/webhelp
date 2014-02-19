module Webhelp
module HamlHelpers

module Http

  # Set the HTTP header 'Content-encoding' field.
  # @param value [String]
  def content_encoding value
    headers['Content-encoding'] = value.to_s;
  end

end#module Http

end#module HamlHelpers
end#module Webhelp
