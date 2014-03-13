module Webhelp
module Minify

class Javascript

  def self.minify source
    IO.popen %w[node_modules/.bin/uglifyjs - --screw-ie8 --mangle sort --compress unsafe], 'w+b' do |u|
      u.write source
      u.close_write
      u.read
    end
  rescue => e
    STDERR.puts "[JSMIN] #{e}"
    source
  end

end#class Javascript

end#module Minify
end#module Webhelp
