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
        "foyerFiscal": {
          "adresse": "12 rue de la mare, 75010 Paris"
        }
      }),
    )
  end
end
