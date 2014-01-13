require 'yaml'

module Webhelp

class RcMapper
  include Util::ReloadingMapper

  DefaultYamlDbPathname = 'rc.yaml'

  def initialize yaml_db_file_path = DefaultYamlDbPathname
    super()
    initialize_reloading_mapper (yaml_db_file_path || DefaultYamlDbPathname)
  end

  alias translate []

end

end