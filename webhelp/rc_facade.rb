module Webhelp

class RcFacade

  # @param mapper [Webhelp::RcMapper]
  def initialize mapper
    @rc = mapper
  end

  def method_missing name
    @rc.translate name
  end

end

end