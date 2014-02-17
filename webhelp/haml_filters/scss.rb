require 'haml'
require 'sass'

module Webhelp
module HamlFilters

class Scss
  include Haml::Filters::Base

  DefaultOptions = {syntax: :scss}

  def render source
    Sass::Engine.new(source, DefaultOptions).render
  end
end#class Scss

end#module HamlFilters
end#module Webhelp
