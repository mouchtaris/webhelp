require 'haml'
require 'sass'

module Webhelp
module MigSassHamlFilters

module MigSass
  include Haml::Filters::Base

  DefaultOptions = {syntax: :sass}

  def render source
    Sass::Engine.new(source, DefaultOptions).render
  end
end

module MigScss
  include Haml::Filters::Base

  DefaultOptions = {syntax: :scss}

  def render source
    Sass::Engine.new(source, DefaultOptions).render
  end
end

end
end
