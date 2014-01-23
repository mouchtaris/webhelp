require 'digest/sha2'

module Webhelp

class RcLocal
  include Webhelp::RcWrapperBase

  def initialize mapper
    initialize_rc_wrapper_base mapper
    @sha = Digest::SHA512.new
  end

  def translate name
    original = URI @mapper.translate name
    (@sha.hexdigest original.to_s) + File.extname(original.path)
  end

  alias translate_local translate

end

end