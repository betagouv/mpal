class Opal
  def initialize(client)
    @client = client
  end

  def creer_dossier(projet, agent_instructeur)
    response = @client.post('/createDossier', body: convertit_projet_en_dossier(projet, agent_instructeur).to_json, verify: false)
    if response.code == 201
      ajoute_id_opal(projet, response.body)
      met_a_jour_statut(projet)
      projet.agent_instructeur = agent_instructeur
      projet.save
    else
      puts "ERREUR: #{response}"
      false
    end
  end

  def ajoute_id_opal(projet, reponse)
    opal = JSON.parse(reponse)
    projet.opal_numero = opal["dosNumero"]
    projet.opal_id = opal["dosId"]
  end

  def met_a_jour_statut(projet)
    projet.statut = :en_cours_d_instruction
  end

  def convertit_projet_en_dossier(projet, agent_instructeur)
    {
      "dosNumeroPlateforme": "#{projet.numero_plateforme}",
      "dosDateDepot": Time.now.strftime("%Y-%m-%d"),
      "utiIdClavis": agent_instructeur.clavis_id,
      "demandeur": {
        "dmdNbOccupants": projet.nb_total_occupants,
        "dmdRevenuOccupants": projet.revenu_fiscal_reference_total,
        "qdmId": 29,
        "cadId": 2,
        "personnePhysique": {
          "civId": 4,
          "pphNom": projet.nom_occupants,
          "pphPrenom": projet.prenom_occupants,
          "adressePostale": {
            "payId": 1,
            "adpLigne1":     projet.adresse_postale.ligne_1,
            "adpLocalite":   projet.adresse_postale.ville,
            "adpCodePostal": projet.adresse_postale.code_postal
          }
        }
      },
      "immeuble": {
        "immAnneeAchevement": projet.annee_construction || 0,
        "ntrId": 1,
        "immSiArretePeril": false,
        "immSiGrilleDegradation": false,
        "immSiInsalubriteAveree": false,
        "immSiDejaSubventionne": false,
        "immSiProcedureInsalubrite": false,
        "adresseGeographique": {
          "adgLigne1": projet.adresse.ligne_1,
          "cdpCodePostal": projet.adresse.code_postal,
          "comCodeInsee": code_insee_suffix(projet.adresse.code_insee),
          "dptNumero": projet.adresse.departement
        }
      }
    }
  end

  def code_insee_suffix(code_insee)
    code_insee[2, code_insee.length]
  end
end
