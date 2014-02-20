module Webhelp
module HamlHelpers

module Opal
  extend Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ config ]

  # Analogous to {haml}:
  # * lookup file stem-named _id_ in the opal directory
  #     if _id_ is a [Symbol], or
  # * compile given code, if _id_ is a [String].
  #
  # Return the compilation result in either case.
  #
  # @param id [String,Symbol] code for compilate ([String])
  #   or file stem-name ([Symbol])
  # @return [String] compiled opal code
  def opal id
    source =
        case id
          when Symbol then (config.opal_dir + "#{id}.rb").read
          when String then id
          else raise ArgumentError.new id.inspect
        end
    Opal.compile source
  end

end#module Opal

end#module HamlHelpers
end#module Webhelp
