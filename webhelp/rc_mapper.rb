module Webhelp

class RcMapper < BasicObject

  def initialize yaml_db_file_path = 'rc.yaml'
    @yaml_db_file_path = yaml_db_file_path.to_s.freeze
    reload!
  end

  def method_missing name
    unless result = @map[name.to_s] then
      reload!
      result = @map[name.to_s]
      ::Kernel.raise "Rc not found: #{name}" unless result
    end
    result
  end

  alias send method_missing

  private
  def reload!
    @map = ::YAML.load ::File.read @yaml_db_file_path
  end

end

end