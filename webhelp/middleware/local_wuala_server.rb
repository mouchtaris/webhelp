require 'sinatra/base'

module Webhelp
module Middleware

class LocalWualaServer < Sinatra::Base

  get '/w/:id.:ext' do |id, ext|
    if local_path = rc_wuala_local.local_path(id)
      then
        if File.exist? local_path
          then send_file local_path
          else logger.warn "[#{rc_wuala_local.inspect}] Does not exist: #{local_path}"
        end
      else
        logger.warn "[#{rc_wuala_local.inspect}] No mapping for #{id}"
        halt 404
    end
  end

end#class LocalWualaServer

end#module Middleware
end#module Webhelp
