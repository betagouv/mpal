require 'dotenv'

RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.register_uri(
      :get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=12&referenceAvis=15",
      content_type: 'application/json',
      body: JSON.generate({
        "declarant1": {
          "nom": "Martin",
          "prenoms": "Pierre",
          "dateNaissance": "19/03/1980"
        },
        "anneeImpots": "2015",
        "nombrePersonnesCharge": 2,
        "foyerFiscal": {
          "adresse": "12 rue de la mare, 75010 Paris"
        },
        "revenuFiscalReference": 29880
      }),
    )

    FakeWeb.register_uri(
      :get, "https://#{ENV['API_PARTICULIER_DOMAIN']}/api/impots/svair?numeroFiscal=INVALID&referenceAvis=INVALID",
      content_type: 'application/json',
      status: ["404", "Not Found"],
      body: JSON.generate({ error: 'An error occured.'}),
    )
  end
end
