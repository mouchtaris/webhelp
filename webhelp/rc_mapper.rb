require 'yaml'

module Webhelp

class RcMapper

  DefaultYamlDbPathname = 'rc.yaml'

  def initialize yaml_db_file_path = DefaultYamlDbPathname
    @yaml_db_file_path = (yaml_db_file_path || DefaultYamlDbPathname).to_s.freeze
    reload!
  end

  def translate name
    unless result = @map[name.to_s] then
      reload!
      result = @map[name.to_s]
      ::Kernel.raise "Rc not found: #{name}" unless result
    end
    result
  end

  def each_name &block
    @map.each_value &block
  end

  private
  def reload!
    @map = ::YAML.load ::File.read @yaml_db_file_path
  end

end

end