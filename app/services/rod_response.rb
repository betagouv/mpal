class RodResponse
  attr_accessor :pris, :instructeur, :operateurs

  def initialize(json)
    @pris        = parse_pris(json)
    @instructeur = parse_instructeur(json)
    @operateurs  = parse_operateurs(json)
  end

private
  def create_or_update_intervenant!(role, attributes)
    clavis_service_id = attributes["id_clavis"]
    raison_sociale    = attributes["raison_sociale"]
    adresse_postale   = attributes["adresse_postale"].values.reject(&:blank?).join(' ')
    phone             = attributes["tel"]
    email             = attributes["email"]

    intervenant = Intervenant.find_by_clavis_service_id(clavis_service_id)
    if intervenant.blank?
      Intervenant.create! clavis_service_id: clavis_service_id, raison_sociale: raison_sociale, adresse_postale: adresse_postale, phone: phone, email: email, roles: [role]
    else
      intervenant.attributes = { raison_sociale: raison_sociale, adresse_postale: adresse_postale, phone: phone, email: email }
      intervenant.roles << role unless intervenant.roles.include? role
      intervenant.save!
      intervenant
    end
  end

  def parse_pris(json)
    create_or_update_intervenant!("pris", json["pris_anah"].first) rescue nil
  end

  def parse_instructeur(json)
    create_or_update_intervenant!("instructeur", json["service_instructeur"].first) rescue nil
  end

  def parse_operateurs(json)
    json_operateurs = json["operation_programmee"].present? ?
                      json["operation_programmee"].map { |op| op["operateurs"] }.flatten :
                      json["operateurs"]

    operateurs_ids = (json_operateurs || []).map do |attributes|
      operateur = create_or_update_intervenant!("operateur", attributes)
      operateur.id
    end
    Intervenant.where(id: operateurs_ids)
  end
end
