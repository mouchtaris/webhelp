module Webhelp

module ShellHelpers
  extend self

  def gzip data
    IO.popen %w[ gzip --force -8 -c - ], 'wb+' do |gz|
      gz << data
      gz.close_write
      gz.read
    end
  end

  def gunzip data
    IO.popen %w[ gzip -d - ], 'wb+' do |gz|
      gz << data
      gz.close_write
      gz.read
    end
  end

end#module ShellHelpers

end#module Webhelp