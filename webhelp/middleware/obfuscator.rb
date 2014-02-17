require 'sinatra/base'
using Util::StringRefinements
using Util::ArrayMapNthRefinement

module Webhelp
module Middleware

class Obfuscator < Sinatra::Base

  def initialize app
    super
    @ob = Webhelp::Obfuscation::DocumentObfuscator.new
  end

  after do
    begin
      case response.content_type
        when %r{^text/html} then body @ob.obfuscate body.join
      end
    rescue ObfuscationInvalidityError => e
      halt 500, e.message
    end
  end#after

end#class Obfuscator

end#module Middleware
end#module Webhelp
