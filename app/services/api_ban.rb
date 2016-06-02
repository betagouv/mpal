class ApiBan
  DOMAIN = ENV['API_BAN_DOMAIN']

  def geocode(adresse)
    response = HTTParty.get(uri(adresse))
    response.code == 200 ? Coordonnees.new(JSON.parse(response.body)) : nil
  end

  def uri(adresse)
    URI.escape "http://#{DOMAIN}/search/?q=#{adresse}"
  end
end

class Coordonnees
  attr_reader :latitude, :longitude
  def initialize(params)
    puts "PARAMS: #{params['features'][0]['geometry']}"
    coords = params['features'][0]['geometry']['coordinates']
    @longitude = coords[0]
    @latitude = coords[1]
  end
end
