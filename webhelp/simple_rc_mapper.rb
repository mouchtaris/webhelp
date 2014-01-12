module Webhelp

class SimpleRcMapper < BasicObject
  include RcMapper

  def initialize yaml_db_pathname = nil
    super()
    initialize_rc_mapper yaml_db_pathname
  end

end

end