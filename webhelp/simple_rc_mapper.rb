module Webhelp

class SimpleRcMapper < BasicObject
  include ::Webhelp::RcMapper

  def initialize yaml_db_pathname = nil
    super
  end

end

end