module Webhelp
module HamlHelpers

module Togr
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ togrer ]

  # Transcribe to greek characters.
  # @param str [String] latin text
  # @return [String] greek text
  def togr str
    ''.tap do |into|
      togrer.transcribe str.to_enum(:each_char), into
    end
  end

end#module Togr

end#module HamlHelpers
end#module Webhelp
