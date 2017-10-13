class OpalError < StandardError
end

class Opal
  def initialize(client)
    @client = client
  end

  def create_dossier!(projet, agent_instructeur)
    Rails.logger.info "[OPAL] dossier creation"
    body = serialize_dossier(projet, agent_instructeur).to_json
    Rails.logger.info "[OPAL] dossier serialized"
    response = @client.post('/createDossier', body: body)
    Rails.logger.info "[OPAL] response received (#{response.code})"
    if response.code != 201
      if response.code == 403
        message = "Accès interdit par Opal"
      else
        message = parse_error_message(response)
      end
      Rails.logger.error "[OPAL] request failed with code '#{response.code}': #{message || response.body}"
      raise OpalError, message
    end

    ajoute_id_opal(projet, response.body)
    met_a_jour_statut(projet)
    projet.agent_instructeur = agent_instructeur
    projet.save
  end

  def update_projet_with_dossier_paiement!(projet, payment)
    Rails.logger.info "[OPAL] dossier ajouter paiement"
    body = serialize_dossier_paiement(projet, payment).to_json
    Rails.logger.info "[OPAL] dossier paiement_serialized"
    response = @client.put('/createDossierPaiement', body: body)
    Rails.logger.info "[OPAL] response received (#{response.code})"
    if response.code != 201
      if response.code == 403
        message = "Accès interdit par Opal"
      else
        message = parse_error_message(response)
      end
      Rails.logger.error "[OPAL] request failed with code '#{response.code}': #{message || response.body}"
      raise OpalError, message
    end
  end

private
  OPAL_CIVILITY_MAPPING = { "mrs" => 2, "mr" => 1 }

  def ajoute_id_opal(projet, reponse_body)
    opal = JSON.parse(reponse_body)
    projet.opal_numero = opal["dosNumero"]
    projet.opal_id = opal["dosId"]
  end


  def met_a_jour_statut(projet)
    projet.statut = :en_cours_d_instruction
  end

  def serialize_civilite(demandeur)
    OPAL_CIVILITY_MAPPING[demandeur.civility] || 1
  end

  def serialize_prenom(demandeur)
    I18n.transliterate(demandeur.prenom[0]).capitalize + demandeur.prenom[1..-1].downcase
  end

  def serialize_nom(demandeur)
    I18n.transliterate(demandeur.nom).upcase
  end

  def project_mail(projet)
    if projet.personne.present?
      projet.personne.email.present? ? projet.personne.email : projet.email
    else
      projet.email
    end
  end

  def project_tel(projet)
    if projet.personne.present?
      projet.personne.tel.present? ? projet.personne.tel : projet.tel
    else
      projet.tel
    end
  end

  def serialize_code_insee(code_insee)
    code_insee[2, code_insee.length]
  end

  def serialize_revenu_fiscal(projet)
    projet.modified_revenu_fiscal_reference ? projet.modified_revenu_fiscal_reference : projet.revenu_fiscal_reference_total
  end

  def serialize_date(date)
    date.strftime("%Y-%m-%d")
  end

  def serialize_dossier(projet, agent_instructeur)
    lignes_adresse_postale  = split_adresse_into_lines(projet.adresse_postale.ligne_1)
    lignes_adresse_geo      = split_adresse_into_lines(projet.adresse.ligne_1)

    {
      "dosNumeroPlateforme": projet.numero_plateforme,
      "dosDateDepot": serialize_date(projet.date_depot),
      "utiIdClavis": agent_instructeur.clavis_id,
      "demandeur": {
        "dmdNbOccupants": projet.nb_total_occupants,
        "dmdRevenuOccupants": serialize_revenu_fiscal(projet),
        "qdmId": 29,
        "cadId": 2,
        "personnePhysique": {
          "civId":            serialize_civilite(projet.demandeur),
          "pphNom":           serialize_nom(projet.demandeur),
          "pphPrenom":        serialize_prenom(projet.demandeur),
          "pphMel":           project_mail(projet),
          "pphTelephone":     project_tel(projet),
          "pphDateNaissance": serialize_date(projet.demandeur.date_de_naissance),
          "adressePostale": {
            "payId": 1,
            "adpLigne1":     lignes_adresse_postale[0],
            "adpLigne2":     lignes_adresse_postale[1],
            "adpLigne3":     lignes_adresse_postale[2],
            "adpLocalite":   projet.adresse_postale.ville,
            "adpCodePostal": projet.adresse_postale.code_postal
          }
        }
      },
      "immeuble": {
        "immAnneeAchevement": projet.demande.annee_construction || 0,
        "ntrId": 1,
        "immSiArretePeril": false,
        "immSiGrilleDegradation": false,
        "immSiInsalubriteAveree": false,
        "immSiDejaSubventionne": false,
        "immSiProcedureInsalubrite": false,
        "adresseGeographique": {
          "adgLigne1": lignes_adresse_geo[0],
          "adgLigne2": lignes_adresse_geo[1],
          "adgLigne3": lignes_adresse_geo[2],
          "cdpCodePostal": projet.adresse.code_postal,
          "comCodeInsee": serialize_code_insee(projet.adresse.code_insee),
          "dptNumero": projet.adresse.departement
        }
      }
    }
  end

  MAX_ADDRESS_LINE_LENGTH = 38

  def split_adresse_into_lines(adresse)
    return [adresse, '', ''] if adresse.length <= MAX_ADDRESS_LINE_LENGTH

    split_index = adresse.rindex(/\s|-/, MAX_ADDRESS_LINE_LENGTH-1)
    ligne_1 = adresse[0..split_index]
    ligne_2 = adresse[(split_index+1)..-1]

    return [ligne_1, ligne_2, ''] if ligne_2.length <= MAX_ADDRESS_LINE_LENGTH

    old_ligne_2 = ligne_2
    split_index = old_ligne_2.rindex(/\s|-/, MAX_ADDRESS_LINE_LENGTH-1)
    ligne_2 = old_ligne_2[0..split_index]
    ligne_3 = old_ligne_2[(split_index+1)..-1]

    [ligne_1, ligne_2, ligne_3]
  end

  def parse_error_message(response)
    message = nil
    begin
      body = response.body.force_encoding Encoding::UTF_8
      message = JSON.parse(body)[0]["message"]
    rescue
    end
    message || "#{response.msg} (#{response.code})"
  end

#CONCERNANT LE DOSSIER DE PAIEMENT

  def serialize_dossier_paiement(projet, payment)
    {
    "typeDePaiement": payment.type_paiement,
    "dateDeDemande": serialize_date(payment.submitted_at),
    "utiIdClavis": projet.agent_instructeur.clavis_id,
    }
  end
end
