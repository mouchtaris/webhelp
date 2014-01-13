module Webhelp

# Provide numbered html class names. Aids in
# row/column colouring.
#
# The Striper works with a class name stem and
# a number of alternating class names. With
# each invocation of #next! the next class name
# is returned (in the form of stem-number).
# When the maximum number of styles is reached,
# the counter is reset and the styles are returned
# anew.

class Striper
  include ArgumentChecking

  # @param stem [String] the stem of the class
  # @param number [Fixnum] the number of alternating classes
  def initialize stem, number
    require_number{:number}
    @stem = stem.to_s.dup.freeze
    @number = number
    @current = number - 1
  end

  def next!
    @current = (@current + 1) % @number
    current
  end

  def current
    "#@stem#@current"
  end

end

end