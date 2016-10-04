require 'dotenv'
RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.register_uri(
      :get,  %r|http://#{ENV['API_BAN_DOMAIN']}|,
      content_type: 'application/json',
      body: JSON.generate({
        "features": [
          {
            "properties": {
              "label": "12 rue de la Mare, 75010 Paris",
              "postcode": "75010",
              "citycode": "75010",
              "name": "12 rue de la Mare",
              "city": "Paris"

            },
            "geometry": {  
              "coordinates": {
                "latitude": "58",
                "longitude": "6"
              }
            }
          }
        ]
      })
    )
  end
end
