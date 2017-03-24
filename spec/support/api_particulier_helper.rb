require 'dotenv'

module Fakeweb
  class ApiParticulier
    NUMERO_FISCAL  = 12
    REFERENCE_AVIS = 15
    INVALID = 'INVALID'

    def self.register_success
      FakeWeb.register_uri(
        :get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=#{NUMERO_FISCAL}&referenceAvis=#{REFERENCE_AVIS}",
        content_type: 'application/json',
        body: JSON.generate({
          "declarant1": {
            "nom": "Martin",
            "prenoms": "Pierre",
            "dateNaissance": "19/03/1980"
          },
          "declarant2": {
              "nom": "Martin",
              "prenoms": "Anne",
              "dateNaissance": "05/06/1979"
          },
          "anneeImpots": "2015",
          "nombrePersonnesCharge": 2,
          "foyerFiscal": {
            "adresse": "12 rue de la Mare, 75010 Paris"
          },
          "revenuFiscalReference": 29880
        }),
      )
    end

    def self.register_invalid
      FakeWeb.register_uri(
        :get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=#{INVALID}&referenceAvis=#{INVALID}",
        content_type: 'application/json',
        status: ["404", "Not Found"],
        body: JSON.generate({ error: 'An error occured.'}),
      )
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Fakeweb::ApiParticulier.register_success
    Fakeweb::ApiParticulier.register_invalid
  end
end
