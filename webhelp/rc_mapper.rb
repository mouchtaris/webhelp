require 'yaml'

module Webhelp

class RcMapper
  include Util::ReloadingMapper

  # see {Util::ReloadingMapper#initialize_reloading_mapper}
  def initialize *dbs
    initialize_reloading_mapper *dbs
  end

  alias translate []

end

end