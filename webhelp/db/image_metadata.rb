module Webhelp
module Db

class ImageMetadataException < RuntimeError
end

class ImageMetadata

  # Generate a {Util::YamlLoader} which load the
  # given db-files.
  #
  # See {Util::YamlLoader} for more info on the
  # argument.
  #
  # @param db_files [Array<String>]
  #
  def new_yaml_loader db_files
    Class.new do
      include Util::YamlLoader
      def initialize db_files
        initialize_yaml_loader *db_files
      end
    end.new db_files
  end
  private :new_yaml_loader

  def initialize *db_files
    @db = new_yaml_loader(db_files).reload.deep_freeze
    @sha = Digest::SHA512.new
  end

  def image? name
    @db[signature_for name]
  end

  def entry name
    image?(name) or (raise ImageMetadataException.new("No entry for #{name}"); nil)
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

end#class ImageMetadata

end#module Db
end#module Webhelp
