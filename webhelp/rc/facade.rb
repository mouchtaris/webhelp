module Webhelp
module Rc

class Facade

  # @param mapper [Webhelp::RcMapper]
  def initialize mapper
    @rc = mapper
  end

  def method_missing name
    @rc.translate name
  end

end#class Facade

end#module Rc
end#module Webhelp
