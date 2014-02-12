require 'uri'
require 'pathname'

module Webhelp

module VendorHelpers

  JQuery2min  = 'http://code.jquery.com/jquery-2.1.0.min.js'
  JQuery2     = 'http://code.jquery.com/jquery-2.1.0.js'

  module JQuerySource_development
    def jquery_source
      Pathname(URI(JQuery2).path).basename.to_s
    end
  end

  module JQuerySource_test
    include JQuerySource_development
  end

  module JQuerySource_preproduction
    def jquery_source
      Pathname(URI(JQuery2min).path).basename.to_s
    end
  end

  module JQuerySource_production
    def jquery_source
      JQuery2min
    end
  end

  def load_jquery
    (Pathname(get_config.public_dir) + "_#{jquery_source}").read
  end

  def jquery_etag
    require 'digest/sha2'
    @__cache__etags__jquery ||= Digest::SHA512.new.hexdigest load_jquery
  end

end#module VendorHelpers

end#module Webhelp
