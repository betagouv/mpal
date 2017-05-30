class RodResponse
  attr_accessor :pris, :instructeur

  def initialize(json)
    @pris        = parse_pris(json["pris_anah"].first)
    @instructeur = parse_instructeur(json["service_instructeur"].first)
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

  def parse_pris(attributes)
    create_or_update_intervenant!("pris", attributes)
  end

  def parse_instructeur(attributes)
    create_or_update_intervenant!("instructeur", attributes)
  end
end
