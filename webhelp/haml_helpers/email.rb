module Webhelp
module HamlHelpers

#
# A Haml Helper for dealing with email addresses.
#
module Email

  # see Webhelp::Html::Email#scramble
  def email email
    Webhelp::Html::Email.scramble email
  end

end#module Email

end#module HamlHelpers
end#module Webhelp
