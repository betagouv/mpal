class ApiBan
  DOMAIN = ENV['API_BAN_DOMAIN']

  def precise(adresse)
    return nil if adresse.empty?
    json_adresse = geocode(adresse)
    coords = json_adresse['features'][0]['geometry']['coordinates']
    longitude = coords[0]
    latitude = coords[1]
    label = json_adresse['features'][0]['properties']['label']
    postcode = json_adresse['features'][0]['properties']['postcode']
    citycode = json_adresse['features'][0]['properties']['citycode']
    departement = postcode[0,2]
    {latitude: latitude, longitude: longitude, departement: departement, adresse: label, citycode: citycode}
  end

  def geocode(adresse)
    response = HTTParty.get(uri(adresse))
    response.code == 200 ? JSON.parse(response.body) : nil
  end

  def uri(adresse)
    URI.escape "http://#{DOMAIN}/search/?q=#{adresse}"
  end
end
