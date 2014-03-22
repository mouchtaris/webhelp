require 'uri'
require 'digest/sha2'
require 'sinatra/base'

module Webhelp
module Rc

class WualaLocal
  include Webhelp::Rc::WrapperBase
  include Util::ArgumentChecking

  # @param wuala_dir [Pathname]
  def initialize(mapper, next_wrapper, wuala_dir:)
    require_path{:wuala_dir}
    @sha                  = Digest::SHA512.new
    @sig_to_url_db        = {}
    @wuala_dir            = wuala_dir
    initialize_rc_wrapper_base mapper, next_wrapper
  end

  # The local path (on the disk) for a given URL
  # signature.
  #
  # @return [String] the local path of a resource
  def local_path signature
    @sig_to_url_db[signature]
  end

  def local_path_from_url url
    sig = WualaLocal.get_signature url
    local_path sig if sig
  end

  def self.get_signature url
    md = /\/(?<sig>\h+)\.\w+$/.match url.to_s
    md[:sig] if md
  end

  private

  # PRIVATE
  # @param name [Symbol]
  def translate_impl name
    original = URI map name
    if original.scheme and original.scheme.downcase == 'wuala'
      sig = signature_for original
      ext = File.extname original.path
      update_db sig, url_for(original)
      "/w/#{sig}#{ext}"
    end
  end

  # PRIVATE
  # Update the sig-to-url database with the given
  # pair.
  #
  # @param sig [String]
  # @param url [String]
  # @return [void]
  def update_db sig, url
    @sig_to_url_db[sig] = url;
  end

  # PRIVATE
  # Original URLs are mapped to unique signatures
  # for each translation. This means that if two
  # URLs translate to the same URL, they will also
  # have the same signature.
  #
  # @param original [URI]
  # @return [String] signature for a url string
  def signature_for original
    @sha.hexdigest url_for original
  end

  # PRIVATE
  # Local url for an original wuala URL, based on
  # "wuala_dir" configuration value.
  #
  # @param original [URI]
  # @return [String] local url
  def url_for original
    (@wuala_dir + "./#{original.path}").cleanpath.to_s
  end

end#class WualaLocal

end#module Rc
end#module Webhelp
