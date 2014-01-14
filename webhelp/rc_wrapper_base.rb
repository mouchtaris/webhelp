module Webhelp

# A base for Webhelp::RcMapper wrappers.
#
# _@mapper_ is the wrapped mapper.

module RcWrapperBase

  def initialize *args, &block
    super
  end

  # @param mapper [Webhelp::RcMapper] the wrapped mapper
  def initialize_rc_wrapper_base mapper
    @mapper = mapper
  end

  def each_name &block
    @mapper.each_name &block
  end

  def each &block
    @mapper.each &block
  end

end

end
