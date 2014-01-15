require 'util/deep_freeze'

module Webhelp

# A manager for images and their resizings.
#
# An ImageManager is responsible for:
# * keeping track of image meta-data (for
#   instance their dimensions),
# * keeping track of their various
#   versions (difference size, quality,
#   and so on).
#
# An ImageManager is backed-up by a resource
# manager.
#
# This ImageManager implementation is also
# backed up by a database, by which it
# becomes known which rc-names are images.
# In this database, to each image name,
# its meta-data are mapped as well.
#
# This image manager does nothing to locate
# or generate image thumbnails or resizings.
# It merely maps such a request to the appropriate
# name-id, and expects the resource manager to
# be aware about such a name.

class ImageManager
  include Util::ReloadingMapper

  # @param rc [Webhelp::RcMapper]
  # @param dbs see {Util::YamlLoader#initialize_yaml_loader}
  def initialize mapper, *dbs
    initialize_reloading_mapper *dbs
    @mapper = mapper
    @map.deep_freeze
  end

  # @param name [String, Symbol] the name of the image resource.
  def img name
    ensure_is_image{}
    @mapper.translate name
  end

  def thumb name, width, height
    ensure_is_image name
    @mapper.translate "thumb_#{name}_#{width}x#{height}"
  end

  def dimensions name
    get_entry(name)[:size]
  end

  private :reload
  private

  def raise_not_image name
    raise ArgumentError.new "#{name} is not in the image-database"
  end

  def ensure_is_image name
     raise_not_image name unless @map.has_key? name
  end

  def get_entry name
    entry = @map[name]
    raise_not_image name unless entry
    entry
  end

end

end
