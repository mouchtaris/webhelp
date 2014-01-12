module Webhelp

class RcMapper < BasicObject

  def initialize yaml_db_file_path = 'rc.yaml'
    @map = ::YAML.load ::File.read yaml_db_file_path
  end

  def method_missing name
    result = @map[name.to_s]
    ::Kernel.raise "Rc not found: #{name}" unless result
    result
  end

  alias send method_missing

end

end