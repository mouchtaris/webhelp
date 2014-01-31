module Webhelp

class RcMap
  include Util::ReloadingMapper

  # see {Util::ReloadingMapper#initialize_reloading_mapper}
  def initialize *dbs
    initialize_reloading_mapper *dbs
  end

end

end