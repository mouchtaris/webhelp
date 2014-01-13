require 'yaml'

module Webhelp

class RcMapper
  include Util::ReloadingMapper

  # @param db_or_path [Hash, String] the database file path or the database itself as a Hash
  def initialize db_or_path
    super()
    initialize_reloading_mapper db_or_path
  end

  alias translate []

end

end