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
  attr_reader :label, :latitude, :longitude
  def initialize(params)
    coords = params['features'][0]['geometry']['coordinates']
    @longitude = coords[0]
    @latitude = coords[1]
    @label = params['features'][0]['properties']['label']
  end
end
