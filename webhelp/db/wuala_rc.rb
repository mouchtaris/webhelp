require 'digest/sha2'
require 'yaml'
require 'fileutils'

module Webhelp
module Db

# TODO is this really used?
class WualaRcDb
  include ArgumentChecking

  Path = 'db/wuala_rc_db.yaml'

  private \
    def new_yaml_loader
      FileUtils::Verbose.touch Path unless File.file? Path
      Object.new.extend(Util::YamlLoader).tap do |yloader|
        yloader.initialize_yaml_loader Path
      end
    end

  def initialize username, local_root, prefix
    require_symbol{:username}
    require_path{:local_root}
    require_string{:prefix}

    yloader     = new_yaml_loader
    @db         = yloader.reload
    @by_url     = Hash[ @db.map do |k, v| [v, k] end ]
    @local_root = local_root
    @username   = username
    @counter    = Util::Counter.new
    @prefix     = prefix.deep_dup
  end

  def add path
    relative_path = path.relative_path_from(@local_root).to_s
    url           = "wuala://#{@username}@f/#{relative_path}"
    if @by_url[url] then
      false
    else
      id            = "#@prefix%03x" % @counter.next!
      @db[id]       = url
      @by_url[url]  = id
      true
    end
  end

  def store!
    File.open Path, 'wb' do |fouts|
      fouts.write @db.to_yaml
    end
  end

end#class WualaRcDb

end#module Db
end#module Webhelp
