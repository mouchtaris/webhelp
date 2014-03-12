module Webhelp
module HamlHelpers

#
# A Haml Helper for rendering haml templates.
#
# Methods ending in -2 use the gen2-style of generation.
#
module Haml
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ config ]

  # A gen2-style content generation with haml and sass.
  #
  # _id_head.haml_ and _id.haml_ are expected to be
  # found in the _views_ directory. The body file is
  # processed first, the head second, and the result
  # returned.
  #
  # @param id [Symbol] basename of the files to process
  # @return [String] the haml process result
  def haml2 id, &block
    head_id = :"#{id}_head"
    # pre-process (running this generates info needed for
    # header generation)
    body = haml id, &block
    haml head_id do body end
  end

end#module Haml

end#module HamlHelpers
end#module Webhelp
