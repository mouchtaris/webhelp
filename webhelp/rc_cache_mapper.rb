module Webhelp

class RcCacheMapper
  include ArgumentChecking

  # @param mapper [Webhelp::RcMapper]
  def initialize mapper
    require_type(Webhelp::RcMapper){:mapper}
    @rc = mapper
  end

  def translate name
    uri = URI @rc.translate name
    id = Digest::MD5.hexdigest uri.to_s
    path = Pathname uri.path
    "#{id}#{path.extname}"
  end

  def each_name &block
    @rc.each_name &block
  end

end

end