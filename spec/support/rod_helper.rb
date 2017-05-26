require 'dotenv'

module Fakeweb
  class Rod
    def self.register_query_for_success
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}intervenants|,
        body: JSON.generate({
          "pris_anah":
            [
              {
                "id_clavis": 5421,
                "raison_sociale": "ADIL du Doubs",
                "adresse_postale":
                  {
                    "adresse1": "1 chemin de Ronde du Fort Griffon",
                    "adresse2": "",
                    "adresse3": "",
                    "code_postal": "25000",
                    "ville": "Besançon"
                  },
                "tel": "03 81 61 92 41",
                "email": "adil25@orange.fr",
                "web": "www.adil25.org"
              }
            ],
          "pris_eie":
            [
              {
                "id_clavis": 5421,
                "raison_sociale": "ADIL du Doubs",
                "adresse_postale":
                  {
                    "adresse1": "1 chemin de Ronde du Fort Griffon",
                    "adresse2": "",
                    "adresse3": "",
                    "code_postal": "25000",
                    "ville": "Besançon"
                  },
                "tel": "03 81 61 92 41",
                "email": "adil25@orange.fr",
                "web": "www.adil25.org"
              }
            ]
        }),
        status: [200, "OK"]
      )
    end

    def self.register_query_for_failure
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}intervenants|,
        body: JSON.generate(
          {
            error: "Applicant's adress is not found. Check if adress is correct"
          }
        ),
        status: [400, "Bad Request"]
      )
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Fakeweb::Rod.register_query_for_success
  end
end
