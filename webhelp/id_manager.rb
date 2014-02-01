module Webhelp

class IdManager
  include ::ArgumentChecking

  def initialize
    @next = 'a'
    @map = {}
    @counter = Util::Counter.new
  end

  # @return [String] the _id_ mapping
  def register id
    raise "#{id} already registered" if @map.has_key? id
    @map[id] = next_mapping
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
    @map[id] ||= next_mapping
  end

  # Create a unique id and register it.
  # @return [String] the unique id mapping
  def next!
    id = @counter.next!
    id = @counter.next! while @map[id]
    register id
  end

  # Clear all registrations/mappings.
  def clear!
    @map.clear;
  end

  private
  def next_mapping
    result = @next.dup.freeze
    @next.next!
    result
  end

end

end