require 'sinatra/base'

module Webhelp
module Middleware

class Obfuscator < Sinatra::Base

  after do
    ob = Webhelp::Obfuscation::DocumentObfuscator.new
    begin
      case response.content_type
        when %r{^text/html} then body ob.obfuscate_document body.join
      end
    rescue Webhelp::Obfuscation::ObfuscationInvalidityError => e
      halt 500, e.message
    end
  end#after

end#class Obfuscator

end#module Middleware
end#module Webhelp
