module Webhelp

class IdManager
  include Util::ArgumentChecking

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

  # _mapping_ must exist as a mapping of a
  # registered id.
  # @return [String] the _id_ for this _mapping_
  def reverse_get mapping
    (@map.rassoc(mapping) || (raise "#{mapping} is not a mapping of a registered id"))[0]
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

  def each_id &block
    @map.deep_dup.each_key &block
  end

  def each &block
    @map.deep_dup.each &block
  end

  def empty?
    @map.empty?
  end

  private
  def next_mapping
    result = @next.dup.freeze
    @next.next!
    result
  end

end

end