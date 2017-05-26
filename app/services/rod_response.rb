class RodResponse
  attr_accessor :pris

  def initialize(json)
    pris_attributes = json["pris_anah"].first

    clavis_service_id = pris_attributes["id_clavis"]
    raison_sociale    = pris_attributes["raison_sociale"]
    adresse_postale   = pris_attributes["adresse_postale"].values.reject(&:blank?).join(' ')
    phone             = pris_attributes["tel"]
    email             = pris_attributes["email"]

    @pris = Intervenant.find_by_clavis_service_id(clavis_service_id)
    if @pris.blank?
      @pris = Intervenant.create! clavis_service_id: clavis_service_id, raison_sociale: raison_sociale, adresse_postale: adresse_postale, phone: phone, email: email, roles: ["pris"]
    else
      @pris.attributes = { raison_sociale: raison_sociale, adresse_postale: adresse_postale, phone: phone, email: email }
      @pris.roles << "pris" unless @pris.roles.include? "pris"
			@pris.save!
    end
  end
end
