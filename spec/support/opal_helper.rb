require 'dotenv'

module Fakeweb
  class Opal
    def self.register_create_dossier_success
      FakeWeb.register_uri(
        :post, %r|#{ENV['OPAL_API_BASE_URI']}sio/json/createDossier|,
        content_type: 'application/json',
        body: JSON.generate({
          "dosNumero": "09500840",
          "dosId": 959496
        }),
        status: [201, "Created"]
      )
    end

    def self.register_create_dossier_failure
      FakeWeb.register_uri(
        :post, %r|#{ENV['OPAL_API_BASE_URI']}sio/json/createDossier|,
        content_type: 'application/json',
        body: JSON.generate([
          {
            message: "Utilisateur inconnu : veuillez-vous connecter à OPAL.",
            code: 1001
          }
        ]),
        status: [422, "Unprocessable Entity"]
      )
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Fakeweb::Opal.register_create_dossier_success
  end
end
