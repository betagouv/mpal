class ApiBan
  DOMAIN = ENV['API_BAN_DOMAIN']

  def geocode(adresse)
    response = HTTParty.get(uri(adresse))
    response.code == 200 ? Adresse.new(JSON.parse(response.body)) : nil
  end

  def uri(adresse)
    URI.escape "http://#{DOMAIN}/search/?q=#{adresse}"
  end
end

class Adresse
  attr_reader :label, :latitude, :longitude, :departement
  def initialize(params)
    coords = params['features'][0]['geometry']['coordinates']
    @longitude = coords[0]
    @latitude = coords[1]
    @label = params['features'][0]['properties']['label']
    postcode = params['features'][0]['properties']['postcode']
    @departement = postcode[0,2]
  end
end
