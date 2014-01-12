module Webhelp

class Image < BasicObject

  def initialize rc = ::Webhelp::SimpleRcMapper.new
    ::ArgumentChecking.require_type(::Webhelp::RcMapper){:rc}
    @rc = rc
  end
  attr_accessor :scope

  def method_missing name
    @scope.haml "%img{src: '#{@rc.send "img_#{name}"}', alt: 'img_#{name}'}"
  end

end

end