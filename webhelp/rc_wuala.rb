require 'uri'

module Webhelp

# An Webhelp::RcMapper wrapper which filters and
# offeres meaningful #translate responses for
# wuala-stored content.
#
# Translations are handled by this mapper if they
# begin with the <wuala://> scheme. Otherwise
# they are forwarded to the wrapped mapper.
#

class RcWuala
  include Webhelp::RcWrapperBase
  extend ::ArgumentChecking

  # @param mapper [Webhelp::RcMapper] the wrapped mapper
  def initialize scene, mapper, next_wrapper
    initialize_rc_wrapper_base mapper, next_wrapper
  end


  private

  def translate_impl name
    original = URI map name
    if original.scheme.downcase == 'wuala' then
      "https://content.wuala.com/contents/#{
        original.user}/public#{original.path}"
    end
  end

end

end
