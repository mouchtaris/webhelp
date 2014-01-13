module Webhelp

class RcImage < BasicObject

  # @param mapper [Webhelp::RcMapper]
  def initialize mapper
    @rc = mapper
  end
  attr_accessor :scope

  def method_missing name
    @scope.haml "%img{src: '#{@rc.translate "img_#{name}"}', alt: 'img_#{name}'}"
  end

end

end