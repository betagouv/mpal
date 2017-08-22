class ApiBan
  def precise(adresse)
    return nil if adresse.blank?

    json_adresse = geocode(adresse)

    return nil if json_adresse.blank? || json_adresse['features'].blank?

    coords      = json_adresse['features'][0]['geometry']['coordinates']
    longitude   = coords[0]
    latitude    = coords[1]
    properties  = json_adresse['features'][0]['properties']
    ligne_1     = properties['name']
    code_postal = properties['postcode']
    code_insee  = properties['citycode']
    ville       = properties['city']
    departement = properties['context'][0,2]
    region      = parse_context(properties['context'])

    Adresse.new({
      latitude:    latitude,
      longitude:   longitude,
      ligne_1:     ligne_1,
      code_postal: code_postal,
      code_insee:  code_insee,
      ville:       ville,
      departement: departement,
      region:      region,
    })
  end

  def self.uri(adresse)
    URI.escape "http://#{ENV['API_BAN_DOMAIN']}/search/?q=#{adresse}&autocomplete=0"
  end

private
  def geocode(adresse)
    api_uri = self.class.uri(adresse)

    Rails.logger.debug "Started Api-Ban request \"#{api_uri}\""
    response = HTTParty.get(api_uri)
    Rails.logger.debug "Completed Api-Ban request (#{response.code})"

    response.code == 200 ? JSON.parse(response.body) : {}
  end

  def parse_context(context)
    /, ([^,(]+)(| \(.*\))$/.match(context)[1]
  end
end

