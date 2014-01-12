module Webhelp

class Image < BasicObject

  # @param rc [Webhelp::RcMapper]
  def initialize rc = ::Webhelp::SimpleRcMapper.new
    @rc = rc
  end
  attr_accessor :scope

  def method_missing name
    @scope.haml "%img{src: '#{@rc.send "img_#{name}"}', alt: 'img_#{name}'}"
  end

end

end