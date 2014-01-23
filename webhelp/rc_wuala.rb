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
  def initialize mapper
    initialize_rc_wrapper_base mapper
  end

  def translate name
    original = URI @mapper.translate name
    if original.scheme == 'wuala'
      then "https://content.wuala.com/contents/#{
              original.user}/public#{original.path}"
      else original
    end
  end

end

end
