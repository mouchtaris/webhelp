module Webhelp
module HamlHelpers

module Preload
  extend ::Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper url opal opal_require ]

  def preload rc_id
    gen2.preload url rcmapper.translate rc_id
  end

  def generate_preloader_function
    urls = gen2.preload.map do |url, _| url.inspect end
    opal_code = "
      #{opal_require :Preload}
      Preload.new.preload [#{urls.join ', '}]"

    "function () {#{opal opal_code}}"
  end

end#module Preload

end#module HamlHelpers
end#module Webhelp
