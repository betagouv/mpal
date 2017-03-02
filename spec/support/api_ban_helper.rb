require 'dotenv'

FAKEWEB_API_BAN_ADDRESS_MARE = "12 rue de la Mare, 75010 Paris"
FAKEWEB_API_BAN_ADDRESS_ROME = "65 rue de Rome, 75008 Paris"
FAKEWEB_API_BAN_ADDRESS_UNKNOWN = "Route de nulle-part, Ailleurs"

RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.register_uri(
      :get, ApiBan.uri(FAKEWEB_API_BAN_ADDRESS_MARE),
      content_type: 'application/json',
      body: JSON.generate({
        "features": [
          {
            "properties": {
              "label": FAKEWEB_API_BAN_ADDRESS_MARE,
              "postcode": "75010",
              "citycode": "75010",
              "name": "12 rue de la Mare",
              "city": "Paris",
              "departement": "75"
            },
            "geometry": {
              "coordinates": [
                6.1,
                58.2
              ]
            }
          }
        ]
      })
    )

    FakeWeb.register_uri(
      :get, ApiBan.uri(FAKEWEB_API_BAN_ADDRESS_ROME),
      content_type: 'application/json',
      body: JSON.generate({
        "features": [
          {
            "properties": {
              "label": FAKEWEB_API_BAN_ADDRESS_ROME,
              "postcode": "75008",
              "citycode": "75008",
              "name": "65 rue de Rome",
              "city": "Paris",
              "departement": "75"

            },
            "geometry": {
              "coordinates": [
                5.8,
                57.9
              ]
            }
          }
        ]
      })
    )

    FakeWeb.register_uri(
      :get, ApiBan.uri(FAKEWEB_API_BAN_ADDRESS_UNKNOWN),
      content_type: 'application/json',
      body: JSON.generate({
        "features": []
      })
    )
  end
end
