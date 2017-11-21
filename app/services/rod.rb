class RodError < StandardError
end

class Rod
  def initialize(client)
    @client = client
  end

  ROLE_MAPPING = {
    "ANAH_SIEGE" => "siege",
    "DREAL" =>      "dreal",
    "DEAT" =>       "deat",
    "DL" =>         "instructeur",
    "DLC2" =>       "instructeur",
    "DLC3" =>       "instructeur",
    "DL_AUT_GES" => "DL_AUT_GES",
    "OPER" =>       "operateur",
    "PRIS" =>       "pris",
  }

  def create_intervenant(clavis_service_id)
    Rails.logger.info %(Started Api-ROD request "#{@client.base_uri}/service/#{clavis_service_id}")
    start = Time.now
    response = @client.get("/service/#{clavis_service_id}")
    Rails.logger.info "Completed Api-ROD request (#{response.code}) in #{Time.now - start}s"
    intervenant = Intervenant.new
    intervenant.raison_sociale = response["raison_sociale"]
    intervenant.adresse_postale = [response["adresse"], response["code_postal"], response["commune"]].reject(&:blank?).join(" ")
    # DEV NOTE: themes à ajouter ?
    intervenant.departements = response["perimetre_geo"]
    intervenant.email = response["email"]
    intervenant.roles = [ROLE_MAPPING[response["type_service"]]].compact  
    intervenant.clavis_service_id = response["id_service"]
    intervenant.phone = response["tel"]
    intervenant
  end

  def create_intervenant!(clavis_service_id)
    intervenant = create_intervenant clavis_service_id
    intervenant.save!
    intervenant
  end

  def query_for(projet)
    Rails.logger.info "Started Api-ROD request \"#{@client.base_uri}/intervenants\""
    start = Time.now
    response = @client.get('/intervenants', query: serialize_demande(projet) )
    Rails.logger.info "Completed Api-ROD request (#{response.code}) in #{Time.now - start}s"

    if response.code != 200
      message = parse_error_message(response)
      Rails.logger.error "[ROD] request failed with code '#{response.code}': #{message || response.body}"
      raise RodError, message
    end

    rod_response = RodResponse.new(JSON.parse(response.body))
    log_successful_query(projet, rod_response)
    rod_response
  end

  def list_intervenants_rod(departement)
    Rails.logger.info "Started Api-ROD request \"#{@client.base_uri}/intpardpt/#{departement}\""
    start = Time.now
    response = @client.get("/intpardpt/#{departement}")
    Rails.logger.info "Completed Api-ROD request (#{response.code}) in #{Time.now - start}s"
    list_intervenants = JSON.parse(response.body)

    return list_intervenants
  end

private
  def serialize_demande(projet)
    thematiques = []
    thematiques << "energie"     if projet.demande.blank? || projet.demande.is_about_energy?
    thematiques << "autonomie"   if projet.demande.blank? || projet.demande.is_about_self_sufficiency?
    thematiques << "insalubrite" if projet.demande.blank? || projet.demande.is_about_unhealthiness?

    {
      "adresse": projet.adresse.description,
      "thematiques": thematiques.join(','),
    }
  end

  def parse_error_message(response)
    begin
      JSON.parse(response.body)["error"]
    rescue
      "#{response.msg} (#{response.code})"
    end
  end

  def log_successful_query(projet, rod_response)
    Rails.logger.info "ROD response for project id #{projet.id}"
    Rails.logger.info "PRIS:        #{rod_response.pris.try(:raison_sociale)}"
    Rails.logger.info "PRIS EIE:    #{rod_response.pris_eie.try(:raison_sociale)}"
    Rails.logger.info "Instructeur: #{rod_response.instructeur.try(:raison_sociale)}"
    Rails.logger.info "Operations:  #{rod_response.operations.map(&:name).join(", ")}"
    Rails.logger.info "Operateurs:  #{rod_response.operateurs.map(&:raison_sociale).join(", ")}"
  end
end
