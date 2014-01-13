module Webhelp

class RcCacheMapper
  include Webhelp::RcWrapperBase

  # @param mapper [Webhelp::RcMapper]
  def initialize mapper
    initialize_rc_wrapper_base mapper
  end

  def translate name
    uri = URI @mapper.translate name
    id = Digest::MD5.hexdigest uri.to_s
    path = Pathname uri.path
    "#{id}#{path.extname}"
  end

end

end