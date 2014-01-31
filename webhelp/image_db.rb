require 'fileutils'
require 'digest/sha2'
require 'util/deep_freeze'

module Webhelp

class ImageDb

  Path = 'db/img_db.yaml'

  private \
    def new_yaml_loader
      FileUtils::Verbose.touch Path unless File.file? Path
      Class.new {
        include Util::YamlLoader
        def initialize
          initialize_yaml_loader Path
        end
      }.new
    end

  def initialize
    @db = new_yaml_loader.reload.deep_freeze
    @sha = Digest::SHA512.new
  end

  def entry name
    @db[signature_for name] || (raise "No entry for #{name}"; nil)
  end

  def size name
    entry(name)[:size]
  end

  def width name
    size(name)[0]
  end

  def height name
    size(name)[1]
  end

  private
  def signature_for name
    @sha.hexdigest name.to_s
  end

end

end
