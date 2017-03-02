class ApiBan
  def precise(adresse)
    return nil if adresse.blank?

    json_adresse = geocode(adresse)

    if json_adresse.blank? || json_adresse['features'].blank?
      return nil
    end

    coords = json_adresse['features'][0]['geometry']['coordinates']
    longitude = coords[0]
    latitude = coords[1]
    adresse_ligne1 = json_adresse['features'][0]['properties']['name']
    code_insee = json_adresse['features'][0]['properties']['citycode']
    code_postal = json_adresse['features'][0]['properties']['postcode']
    ville = json_adresse['features'][0]['properties']['city']
    departement = code_postal[0,2]

    {
      latitude: latitude,
      longitude: longitude,
      departement: departement,
      adresse_ligne1: adresse_ligne1,
      code_insee: code_insee,
      code_postal: code_postal,
      ville: ville
    }
  end

  def self.uri(adresse)
    URI.escape "http://#{ENV['API_BAN_DOMAIN']}/search/?q=#{adresse}"
  end

  private

  def geocode(adresse)
    api_uri = self.class.uri(adresse)

    logger.debug "Started Api-Ban request \"#{api_uri}\""
    response = HTTParty.get(api_uri)
    logger.debug "Completed Api-Ban request (#{response.code})"

    response.code == 200 ? JSON.parse(response.body) : {}
  end

  def logger
    Rails.logger
  end
end
