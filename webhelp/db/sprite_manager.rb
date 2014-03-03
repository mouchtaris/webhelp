module Webhelp
module Db

class SpriteManagerException < RuntimeError
end

class SpriteManager

  def new_yaml_loader db_files
    Class.new do
      include Util::YamlLoader
      def initialize db_files
        initialize_yaml_loader *db_files
      end
    end.
    new db_files
  end
  private :new_yaml_loader

  def reload!
    @db = @yaml_reloader.reload.deep_freeze
  end

  def initialize *db_files
    @yaml_reloader = new_yaml_loader db_files
    reload!
  end

  def sprite? id
    @db[id]
  end

  def entry id
    sprite?(id) or (raise SpriteManagerException.new("No such sprite entry \"#{id}\""); nil)
  end

  def rc id
    entry(id)[:rc]
  end

  def rc? id
    rc id
  rescue SpriteManagerException
  end

  def width id
    entry(id)[:width]
  end

  def width? id
    width id
  rescue SpriteManagerException
  end

  def height id
    entry(id)[:height]
  end

  def height? id
    height id
  rescue SpriteManagerException
  end

  def x id
    entry(id)[:x]
  end
  alias offset_x x

  def x? id
    x id
  rescue SpriteManagerException
  end
  alias offset_x? x?

  def y id
    entry(id)[:y]
  end
  alias offset_y y

  def y? id
    y id
  rescue SpriteManagerException
  end
  alias offset_y? y?

  def hover_rc id
    e = entry id
    e[:hover_rc] or e[:rc]
  end

  def hover_rc? id
    hover_rc id
  rescue SpriteManagerException
  end

end#class SpriteManager

end#module Db
end#module Webhelp
