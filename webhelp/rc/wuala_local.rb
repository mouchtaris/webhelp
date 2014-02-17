require 'uri'
require 'digest/sha2'
require 'sinatra/base'

module Webhelp
module Rc

class WualaLocal
  include Webhelp::RcWrapperBase
  extend ::ArgumentChecking

  def initialize scene, mapper, next_wrapper
    require_scene{:scene}
    @scene                = scene
    @sha                  = Digest::SHA512.new
    @sig_to_url_db        = {}
    @sinatra_middleware   = new_sinatra_middleware
    initialize_rc_wrapper_base mapper, next_wrapper
  end

  # The local path (on the disk) for a given URL
  # signature.
  #
  # @return [String] the local path of a resource
  def local_path signature
    @sig_to_url_db[signature]
  end

  # Given a sinatra (rack) application, add the
  # translated URL handling middleware as a middleware.
  #
  # @param app [Sinatra::Base]
  # @return [void]
  def use_middleware app
    app.use @sinatra_middleware;
  end


  private

  # PRIVATE
  # Create a new sinatra middleware application for handling
  # url-s generated by this rc-translator.
  #
  # @return [Sinatra::Base] a new sinatra middleware application
  def new_sinatra_middleware
    this = self
    Class.new Sinatra::Base do
      get '/w/:id.:ext' do |id, ext|
        if local_path = this.local_path(id)
          then
            if File.exist? local_path
              then send_file local_path
              else logger.warn "[#{this.inspect}] Does not exist: #{local_path}"
            end
          else
            logger.warn "[#{this.inspect}] No mapping for #{id}"
            halt 404
        end
      end
    end
  end

  # PRIVATE
  # @param name [Symbol]
  def translate_impl name
    original = URI map name
    if original.scheme and original.scheme.downcase == 'wuala'
      sig = signature_for original
      ext = File.extname original.path
      update_db sig, url_for(original)
      "w/#{sig}#{ext}"
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
  # @param original [String]
  # @return [String] signature for a url string
  def signature_for original
    @sha.hexdigest url_for original
  end

  # PRIVATE
  # Local url for an original wuala URL, based on
  # "wuala_dir" configuration value.
  #
  # @param original [String]
  # @return [String] local url
  def url_for original
    "#{@scene.config.wuala_dir}#{original.path}"
  end

  # PRIVATE
  # check that scene responds to :config.
  #
  # @return [void]
  def require_scene &block
    name = block[]
    scene = eval name.to_s, block.binding
    raze = lambda do raise "Scene object not compliant" end
    raze[] unless scene.respond_to? :config
  end

end#class WualaLocal

end#module Rc
end#module Webhelp
