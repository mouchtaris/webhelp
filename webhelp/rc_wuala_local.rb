require 'uri'
require 'digest/sha2'

module Webhelp

class RcWualaLocal
  include Webhelp::RcWrapperBase
  extend ::ArgumentChecking

  def initialize scene, mapper, next_wrapper
    require_scene{:scene}
    @scene            = scene
    @sha              = Digest::SHA512.new
    @sig_to_url_db    = {}
    initialize_rc_wrapper_base mapper, next_wrapper
  end

  def local_path signature
    @sig_to_url_db[signature]
  end


  private

  def translate_impl name
    original = URI map name
    if original.scheme and original.scheme.downcase == 'wuala'
      url = url_for original
      sig = signature_for original
      ext = File.extname original.path
      update_db sig, url
      "w/#{sig}#{ext}"
    end
  end

  def update_db sig, url
    @sig_to_url_db[sig] = url
  end

  def signature_for original
    @sha.hexdigest url_for original
  end

  def url_for original
    "#{@scene.config.wuala_dir}#{original.path}"
  end

  def require_scene &block
    name = block[]
    scene = eval name.to_s, block.binding
    raze = lambda do raise "Scene object not compliant" end
    raze[] unless scene.respond_to? :config
  end

end

end