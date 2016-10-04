class Opal
  def initialize(client)
    @client = client
  end

  def creer_dossier(projet)
    response = @client.post('/createDossier', body: convertit_projet_en_dossier(projet).to_json)
    response.code == 201 ? ajoute_id_opal(projet, response.body) : false
  end

  def ajoute_id_opal(projet, reponse)
    opal = JSON.parse(reponse)
    projet.opal_numero = opal["dosNumero"]
    projet.opal_id = opal["dosId"]
    projet.save
  end

  def convertit_projet_en_dossier(projet)
    {
      "dosNumeroPlateforme": "3007",
      "dosDateDepot": Time.now.strftime("%Y-%m-%d"),
      "utiIdClavis": "5425",
      "demandeur": {
        "dmdNbOccupants": projet.nb_total_occupants,
        "dmdRevenuOccupants": projet.calcul_revenu_fiscal_reference_total(2015),
        "qdmId": 29,
        "cadId": 2,
        "personnePhysique": {
          "civId": 1,
          "pphNom": "Rafu",
          "pphPrenom": "Caroline",
          "adressePostale": {
            "payId": 1,
            "adpLigne1": "27 rue des écoles",
            "adpLocalite": "Eragny",
            "adpCodePostal": "95610"
          }
        }
      },
      "immeuble": {
        "immAnneeAchevement": projet.annee_construction,
        "ntrId": 1,
        "immSiArretePeril": false,
        "immSiGrilleDegradation": false,
        "immSiInsalubriteAveree": false,
        "immSiDejaSubventionne": false,
        "immSiProcedureInsalubrite": false,
        "adresseGeographique": {
          "adgLigne1": "27 rue des écoles",
          "cdpCodePostal": "95610",
          "comCodeInsee": "218",
          "dptNumero": "95"
        }
      }
    }
  end
end
