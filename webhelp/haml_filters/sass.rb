require 'haml'
require 'sass'

module Webhelp
module HamlFilters

class Sass
  include Haml::Filters::Base

  DefaultOptions = {syntax: :sass}

  def render source
    Sass::Engine.new(source, DefaultOptions).render
  end
end#class Sass

end#module HamlFilters
end#module Webhelp
