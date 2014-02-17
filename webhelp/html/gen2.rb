require 'util/deep_dup'

module Webhelp
module Html

# Helpers for 2-phase parsing/output generation.
module Gen2
  include Util::ArgumentChecking

  def initialize_gen2
    @gen2_morecss = {}
  end

  def morecss selector, rules
    if selector or rules then
      require_symbol{:selector}
      require_respond_to(:each){:rules}
      rules.each do |name, value|
        require_string{:name}
        require_string{:value}
      end
      _morecss_append selector, rules;
    else
      @gen2_morecss.deep_dup.freeze
    end
  end


  private

  def _morecss_append selector, rules
    @gen2_morecss[selector] ||= all_rules = {}
    rules.each do |name, value|
      name = name.downcase
      all_rules[name] = value
    end
  end

end#module Gen2

end#module Html
end#module Webhelp
