require 'dotenv'

module Fakeweb
  class ApiBan
    ADDRESS_MARE = "12 rue de la Mare, 75010 Paris"
    ADDRESS_ROME = "65 rue de Rome, 75008 Paris"
    ADDRESS_UNKNOWN = "Route de nulle-part, Ailleurs"

    def self.register_mare_uri
      FakeWeb.register_uri(
        :get, ::ApiBan.uri(ADDRESS_MARE),
        content_type: 'application/json',
        body: JSON.generate({
          "features": [
            {
              "properties": {
                "label": ADDRESS_MARE,
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
    end

    def self.register_rome_uri
      FakeWeb.register_uri(
        :get, ::ApiBan.uri(ADDRESS_ROME),
        content_type: 'application/json',
        body: JSON.generate({
          "features": [
            {
              "properties": {
                "label": ADDRESS_ROME,
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
    end

    def self.register_unknown_uri
      FakeWeb.register_uri(
        :get, ::ApiBan.uri(ADDRESS_UNKNOWN),
        content_type: 'application/json',
        body: JSON.generate({
          "features": []
        })
      )
    end

    def self.register_all_unavailable
      FakeWeb.clean_registry
      FakeWeb.register_uri(
        :get, %r|http://#{ENV['API_BAN_DOMAIN']}|,
        content_type: 'application/json',
        status: ['503', 'Service Unavailable'],
        body: nil
      )
    end

    def self.register_all_unknown
      FakeWeb.clean_registry
      FakeWeb.register_uri(
        :get, %r|http://#{ENV['API_BAN_DOMAIN']}|,
        content_type: 'application/json',
        body: JSON.generate({
          "features": []
        })
      )
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Fakeweb::ApiBan.register_mare_uri
    Fakeweb::ApiBan.register_rome_uri
    Fakeweb::ApiBan.register_unknown_uri
  end
end
