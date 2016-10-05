class ApiBan
  DOMAIN = ENV['API_BAN_DOMAIN']

  def precise(adresse)
    return nil if adresse.empty?
    json_adresse = geocode(adresse)
    coords = json_adresse['features'][0]['geometry']['coordinates']
    longitude = coords[0]
    latitude = coords[1]
    adresse_ligne1 = json_adresse['features'][0]['properties']['name']
    code_insee = json_adresse['features'][0]['properties']['citycode']
    postcode = json_adresse['features'][0]['properties']['postcode']
    ville = json_adresse['features'][0]['properties']['city']
    departement = postcode[0,2]
    {latitude: latitude, longitude: longitude, departement: departement, adresse_ligne1: adresse_ligne1, code_insee: code_insee, code_postal: postcode, ville: ville}
  end

  def geocode(adresse)
    response = HTTParty.get(uri(adresse))
    response.code == 200 ? JSON.parse(response.body) : nil
  end

  def uri(adresse)
    URI.escape "http://#{DOMAIN}/search/?q=#{adresse}"
  end
end
