require 'fileutils'
require 'digest/sha2'
require 'util/deep_freeze'

module Webhelp

class ImageDb

  Path = 'db/img_db.yaml'

  private \
    def new_yaml_loader
      FileUtils::Verbose.touch Path unless File.file? Path 
      Class.new do
        include Util::YamlLoader
        def initialize
          initialize_yaml_loader Path
        end
      end.new
    end

  def initialize
    @db = new_yaml_loader.reload.deep_freeze
    @sha = Digest::SHA512.new
  end

  def entry url
    @db[signature_for url]
  end

  def size url
    entry(url)[:size]
  end

  def width url
    size(url)[0]
  end

  def height url
    size(url)[1]
  end

  private
  def signature_for url
    @sha.hexdigest url
  end

end

end
