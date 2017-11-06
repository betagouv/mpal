require 'dotenv'

module Fakeweb
  class Rod
    FakeResponse = {
      "id_service": "1234",
      "raison_sociale": "DREAL Provence-Alpes-Côte d'Azur",
      "tel": "0102030405",
      "email": "contact@example.com",
      "adresse": "16 Rue Zattara CS 70248",
      "code_postal": "13331",
      "commune": "MARSEILLE CEDEX",
      "type_service": "DREAL",
      "autorite_gestion": false,
      "type_perimetre_geo": "region",
      "perimetre_geo": [
        "04",
        "05",
        "06",
        "13",
        "83",
        "84"
      ]
    }.freeze

    def self.register_intervenant
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}service|,
        body: JSON.generate(FakeResponse),
        status: [200, "OK"]
      )
    end

    def self.register_query_for_success_without_operation_programmee
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}intervenants|,
        body: JSON.generate(
          {
            "code_commune": "25411",
            "type_departement": "Non déployé",
            "operateurs":
              [
                {
                  "id_clavis": 5262,
                  "raison_sociale": "SOLIHA 25-90",
                  "email": "demo-operateur@anah.gouv.fr",
                  "siret": "",
                  "adresse_postale":
                    {
                      "adresse": "30 rue Caporal Peugeot",
                      "code_postal": "25000",
                      "ville": "Besançon"
                    },
                  "tel": "",
                  "web": ""
                },
                {
                  "id_clavis": 5267,
                  "raison_sociale": "AJJ",
                  "email": "operateur25-1@anah.gouv.fr",
                  "siret": "",
                  "adresse_postale":
                    {
                      "adresse": "",
                      "code_postal": "",
                      "ville": ""
                    },
                  "tel": "",
                  "web": ""
                }
              ],
          }.merge(other_intervenants)
        ),
        status: [200, "OK"]
      )
    end

    def self.register_query_for_success_with_operation
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}intervenants|,
        body: JSON.generate(
          {
            "code_commune": "25411",
            "type_departement": "Non déployé",
            "operation_programmee":
              [
                {
                  "libelle": "PIG",
                  "code_opal": "1A",
                  "operateurs":
                    [
                      {
                        "id_clavis": 5262,
                        "raison_sociale": "SOLIHA 25-90",
                        "email": "demo-operateur@anah.gouv.fr",
                        "siret": "",
                        "adresse_postale":
                          {
                            "adresse": "30 rue Caporal Peugeot",
                            "code_postal": "25000",
                            "ville": "Besançon"
                          },
                        "tel": "",
                        "web": ""
                      }
                    ]
                }
              ],
          }.merge(other_intervenants)
        ),
        status: [200, "OK"]
      )
    end

    def self.register_query_for_success_with_operations
      FakeWeb.register_uri(
        :get, %r|#{ENV['ROD_API_BASE_URI']}intervenants|,
        body: JSON.generate(
          {
            "code_commune": "25411",
            "type_departement": "Non déployé",
            "operation_programmee":
              [
                {
                  "libelle": "PIG",
                  "code_opal": "1A",
                  "operateurs":
                    [
                      {
                        "id_clavis": 5262,
                        "raison_sociale": "SOLIHA 25-90",
                        "email": "demo-operateur@anah.gouv.fr",
                        "siret": "",
                        "adresse_postale":
                          {
                            "adresse": "30 rue Caporal Peugeot",
                            "code_postal": "25000",
                            "ville": "Besançon"
                          },
                        "tel": "",
                        "web": ""
                      }
                    ]
                },
                {
                  "libelle": "PORCINET",
                  "code_opal": "1B",
                  "operateurs":
                    [
                      {
                        "id_clavis": 5267,
                        "raison_sociale": "AJJ",
                        "email": "operateur25-1@anah.gouv.fr",
                        "siret": "",
                        "adresse_postale":
                          {
                            "adresse": "",
                            "code_postal": "",
                            "ville": ""
                          },
                        "tel": "",
                        "web": ""
                      }
                    ]
                }
              ],
          }.merge(other_intervenants)
        ),
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
    Fakeweb::Rod.register_query_for_success_without_operation_programmee
  end
end

private
  def other_intervenants
    {
      "service_instructeur":
        [
          {
            "id_clavis": 5054,
            "raison_sociale": "Direction Départementale des Territoires du Doubs",
            "email": "ddt@doubs.gouv.fr",
            "siret": "",
            "adresse_postale":
              {
                "adresse1": "6 Rue Roussillon",
                "adresse2": "",
                "adresse3": "",
                "code_postal": "25003",
                "ville": "BESANCON CEDEX"
              },
            "tel": "03 81 65 62 62",
            "web": ""
          }
        ],
      "dlc2":
        [
          {
            "id_clavis": 5161,
            "type": "DLC2",
            "raison_sociale": "CONSEIL DÉPARTEMENTAL DU DOUBS",
            "email": "info@doubs.fr",
            "siret": "39836751600075",
            "adresse_postale":
              {
                "adresse1": "Hôtel du département 7, avenue de la Gare-d'Eau",
                "adresse2": "",
                "adresse3": "",
                "code_postal": "25031",
                "ville": "BESANçON CEDEX"
              },
            "tel": "0381258125",
            "web": ""
          }
        ],
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
            "id_clavis": 5422,
            "raison_sociale": "ADIL Doudoux",
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
    }
  end
