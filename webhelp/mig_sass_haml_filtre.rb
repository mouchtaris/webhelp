require 'haml'
require 'sass'

module Webhelp
module MigSassHamlFiltre

module MigSass
  include Haml::Filters::Base

  def render source
    Sass::Engine.new(source, syntax: :sass).render
  end

end

end
end
