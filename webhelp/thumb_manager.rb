module Webhelp

class ThumbManager

  def initialize
  end

  def thumb_id rc_id, width, height
    :"t_#{rc_id}_#{width || 'x'}x#{height || 'x'}"
  end

end

end