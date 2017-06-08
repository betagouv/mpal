class RodError < StandardError
end

class Rod
  def initialize(client)
    @client = client
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

    RodResponse.new(JSON.parse(response.body))
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
end
