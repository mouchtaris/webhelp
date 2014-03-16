module Webhelp
module HamlHelpers

module Opal
  include Util::ArgumentChecking
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
          when Symbol then opal_require id
          when String then id
          else raise ArgumentError.new id.inspect
        end
    ::Opal.compile source
  end

  # Lookup and return source code of an opal-ruby
  # file.
  #
  # @param id [Symbol] name of the file to lookup -- no ext
  # @return [String] the code in that file
  def opal_require name
    require_symbol{:name}
    (config.opal_dir + "#{name}.rb").read
  end

end#module Opal

end#module HamlHelpers
end#module Webhelp
