module Webhelp

class RcCache < ::Webhelp::RcMapper

  def initialize yaml_db_pathname = nil
    super
  end

  def translate name
    uri = URI super
    id = Digest::MD5.hexdigest uri.to_s
    path = Pathname uri.path
    "#{id}#{path.extname}"
  end

end

end