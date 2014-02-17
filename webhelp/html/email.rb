using Util::Refinements::DeepDup

module Webhelp
module Html

module Email
  extend self

  # Scramble an email (or image it) and return
  # the appropriate html piece for it.
  #
  # @param email [String] an email string
  # @return [String] an html piece diplaying this
  #   email
  # @todo make this method meaningful
  def scramble email
    # TODO implement for real
    email.to_s.dup.freeze
  end

end#module Email

end#module Html
end#module Webhelp
