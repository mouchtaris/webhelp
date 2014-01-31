require 'digest/sha2'

module Webhelp

class RcLocal
  include Webhelp::RcWrapperBase

  def initialize mapper, next_wrapper
    initialize_rc_wrapper_base mapper, next_wrapper
    @sha = Digest::SHA512.new
  end


  private

  def translate_impl name
    original = URI @mapper.translate name
    @sha.hexdigest(original.to_s) + File.extname(original.path)
  end

end

end