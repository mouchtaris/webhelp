module Webhelp
module Rc

# A base for Webhelp::RcMapper wrappers.
#
# _@mapper_ is the wrapped mapper.

module WrapperBase

  def initialize *args, &block
    super
  end

  # @param mapper [Webhelp::RcMapper] the wrapped mapper
  def initialize_rc_wrapper_base mapper, next_wrapper
    @mapper       = mapper
    @next_wrapper = next_wrapper
  end

  def each_name &block
    @mapper.each_name &block
  end

  def translate name
    translate_impl name or translate_next name
  end


  protected

  def map name
    @mapper[name]
  end


  private

  def translate_next name
    if @next_wrapper
      then @next_wrapper.translate name
      else @mapper[name]
    end
  end

end#module WrapperBase

end#module Rc
end#module Webhelp
