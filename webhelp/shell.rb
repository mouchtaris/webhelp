module Webhelp

class Shell
class << self

  def has? command
    IO.popen [ command ] do end
    true
  rescue Errno::ENOENT => _
    false
  end

  def gzip?
    has? :gzip
  end

  def gzip data
    IO.popen %w[ gzip --force -8 -c - ], 'wb+' do |gz|
      gz << data
      gz.close_write
      gz.read
    end
  end

  alias gunzip? gzip?

  def gunzip data
    IO.popen %w[ gzip -d - ], 'wb+' do |gz|
      gz << data
      gz.close_write
      gz.read
    end
  end

end#class<<self
end#class Shell

end#module Webhelp
