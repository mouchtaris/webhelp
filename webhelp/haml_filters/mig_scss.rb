require 'haml'
require 'sass'

module Webhelp
module HamlFilters

module MigScss
  include Haml::Filters::Base

  DefaultOptions = {syntax: :scss}

  def render source
    Sass::Engine.new(source, DefaultOptions).render
  end
end#module Scss

end#module HamlFilters
end#module Webhelp
