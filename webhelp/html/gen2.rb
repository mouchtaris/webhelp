require 'util/deep_dup'

module Webhelp
module Html

# Helpers for 2-phase parsing/output generation.
class Gen2
  include Util::ArgumentChecking

  def initialize
    @gen2_morecss = {}
  end

  # @param selector [Symbol] the css selector (literally)
  # @param rules [#each => (String, String)] an array
  #     of property - value pairs
  def morecss selector, rules
    if selector or rules then
      require_symbol{:selector}
      require_respond_to(:each){:rules}
      rules.each do |name, value|
        require_string{:name}
        require_string{:value}
      end
      _morecss_add selector, rules;
    else
      @gen2_morecss.deep_dup.freeze
    end
  end


  private

  # Create a new entry for the given selector
  # only if it does not exist.
  def _morecss_add selector, rules
    @gen2_morecss[selector] ||=
    rules.map do |name, value|
      [name.downcase, value]
    end.
    to_h
  end

  # Append all rules to any existing or not
  # selector rule-set.
  def _morecss_append selector, rules
    @gen2_morecss[selector] ||= all_rules = {}
    rules.each do |name, value|
      name = name.downcase
      all_rules[name] = value
    end
  end

end#class Gen2

end#module Html
end#module Webhelp
