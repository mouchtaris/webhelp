module Webhelp

class IdManager
  include ::ArgumentChecking

  def initialize
    @next = 'a'
    @map = {}
  end

  # @return [String] the _id_ mapping
  def register id
    raise "#{id} already registered" if @map.has_key? id
    @map[id] = next!
  end

  # _id_ must be registered.
  # @return [String] the _id_ mapping
  def get id
    @map[id] || (raise "#{id} not registered")
  end

  # If _id_ is registered, retrieve the mapping.
  # If not, register it and return the mapping.
  # @return [String] the _id_ mapping
  def [] id
    @map[id] ||= next!
  end

  private
  def next!
    result = @next.dup.freeze
    @next.next!
    result
  end

end

end