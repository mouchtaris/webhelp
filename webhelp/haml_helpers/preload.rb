module Webhelp
module HamlHelpers

module Preload
  extend ::Util::InstanceRequirementsChecker

  InstanceRequirements = %i[ rcmapper ]

  def preload rc_id
    gen2.preload rcmapper.translate rc_id
  end

  def import_preload_js
    code = gen2.preload.map do |url, _|
      escaped_url = url.to_s.gsub ',', '\,'
      "HTTP.get %Q,#{escaped_url},\n"
    end.join
    opal "Document.ready? do #{code} end" if code
  end

end#module Preload

end#module HamlHelpers
end#module Webhelp
