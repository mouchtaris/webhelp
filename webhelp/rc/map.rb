module Webhelp
module Rc

class Map
  include Util::ReloadingMapper

  # see {Util::ReloadingMapper#initialize_reloading_mapper}
  def initialize *dbs
    initialize_reloading_mapper *dbs
  end

end#class Map

end#module Rc
end#module Webhelp
