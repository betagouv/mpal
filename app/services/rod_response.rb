class RodResponse
  attr_accessor :pris, :pris_eie, :instructeur, :operateurs, :operations, :name_operation, :code_opal

  def initialize(json)
    @name_operation = ""
    @code_opal      = ""
    @pris           = parse_pris(json)
    @pris_eie       = parse_pris_eie(json)
    @instructeur    = parse_instructeur(json)
    @operateurs     = parse_operateurs(json)
    @operations     = parse_operations(json)
  end

  def scheduled_operation?
    operations.count == 1 && operateurs.count == 1
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

  def parse_pris_eie(json)
    create_or_update_intervenant!("pris", json["pris_eie"].first) rescue nil
  end

  def parse_instructeur(json)
    create_or_update_intervenant!("instructeur", json["service_instructeur"].first) rescue nil
  end

  def parse_operateurs(json)
    json_operateurs = json["operation_programmee"].present? ?
                      json["operation_programmee"].map { |op| op["operateurs"] }.flatten :
                      json["operateurs"]

    (json_operateurs || []).map { |attributes| create_or_update_intervenant!("operateur", attributes) }
  end

  def parse_operations(json)
    if json["operation_programmee"].present?
      (json["operation_programmee"]).map do |attributes|
        @name_operation       = attributes["libelle"]
        @code_opal            = attributes["code_opal"]
        operateur_clavis_ids = attributes["operateurs"].map { |o| o["id_clavis"] }

        operateurs = Intervenant.where clavis_service_id: operateur_clavis_ids
        operation  = Operation.find_by_code_opal code_opal
        if operation.blank?
          Operation.create! name: name_operation, code_opal: code_opal, operateurs: operateurs
        else
          operation.update! name: name_operation, operateurs: operateurs
          operation
        end
      end
    else
      []
    end
  end

end

