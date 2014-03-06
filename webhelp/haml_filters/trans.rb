require 'haml'

module Webhelp
module HamlFilters

module Trans
  include Haml::Filters::Base

  def render source
    trans source
  end

end#module Trans

end#module HamlFilters
end#module Webhelp
