require 'uri'
require 'pathname'

module Webhelp

# An Webhelp::RcMapper wrapper which filters and
# offeres meaningful #translate responses for
# wuala-stored content.
#
# Translations are handled by this mapper if they
# begin with the <wuala://> scheme. Otherwise
# they are forwarded to the wrapped mapper.
#
# The wuala username must be provided upon
# construction.

class RcWuala
  include Webhelp::RcWrapperBase

  # The _original_mapper_ is required because
  # it holds information about which resources are
  # wuala-hanlded and which not.
  #
  # After this decision is made, the request is
  # forwarded (if it must) to _mapper_, which could
  # possibly be wrapped.
  #
  # @param original_mapper [Webhelp::RcMapper] the original mapper (not wrapped)
  # @param mapper [Webhelp::RcMapper] the wrapped mapper
  # @param local_serve [Bool] serve wuala files locally
  def initialize original_mapper, mapper, local_serve
    initialize_rc_wrapper_base mapper
    @original = original_mapper
    @local_serve = local_serve
  end

  def translate name
    original = URI @original.translate name
    if original.scheme == 'wuala'
      then
        if @local_serve
          then
            "/wuala#{original.path}"
          else
            "https://content.wuala.com/contents/#{
              original.user}/public#{
              original.path}"
        end
      else
        @mapper.translate name
    end
  end

end

end
