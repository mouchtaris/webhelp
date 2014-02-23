module Webhelp
module Middleware

class LocalWualaServer < Sinatra::Base

  def initialize app, root_app
    super app
    @root_app = root_app
  end

  get '/w/:id.:ext' do |id, ext|
    if local_path = @root_app.rcwualalocal.local_path(id)
      then
        if File.exist? local_path
          then send_file local_path
          else halt 404, "Does not exist: #{local_path}"
        end
      else
        halt 404, "No mapping for #{id}"
    end
  end

end#class LocalWualaServer

end#module Middleware
end#module Webhelp
