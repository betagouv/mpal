class ProjetInitializer
  def initialize(service_particulier = nil, service_adresse = nil)
    @service_particulier = service_particulier
    @service_adresse = service_adresse || ApiBan.new
  end

  def initialize_projet(numero_fiscal, reference_avis)
    projet = Projet.new

    @service_particulier ||= ApiParticulier.new(numero_fiscal, reference_avis)
    contribuable = @service_particulier.retrouve_contribuable

    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal

    begin
      projet.adresse_postale = self.precise_adresse(contribuable.adresse)
    rescue => e
      logger.info "ProjetInitializer: l'adresse n'a pas pu être localisée (#{e})"
    end

    initialize_avis_imposition(projet, numero_fiscal, reference_avis, contribuable)

    projet
  end

  def initialize_avis_imposition(projet, numero_fiscal, reference_avis, contribuable = nil)
    unless contribuable
      @service_particulier ||= ApiParticulier.new(numero_fiscal, reference_avis)
      contribuable = @service_particulier.retrouve_contribuable
      return unless contribuable
    end

    declarant_count = contribuable.declarants[1].present? ? 2 : 1
    avis_imposition = projet.avis_impositions.build
    avis_imposition.reference_avis = reference_avis
    avis_imposition.numero_fiscal = numero_fiscal
    avis_imposition.annee = contribuable.annee_revenus
    avis_imposition.declarant_1 = "#{contribuable.declarants[0][:prenom]} #{contribuable.declarants[0][:nom]}"
    avis_imposition.declarant_2 = "#{contribuable.declarants[1][:prenom]} #{contribuable.declarants[1][:nom]}" if 2 <= declarant_count
    avis_imposition.nombre_personnes_charge = contribuable.nombre_personnes_charge
    avis_imposition.revenu_fiscal_reference = contribuable.revenu_fiscal_reference

    contribuable.declarants.each_with_index do |declarant, index|
      avis_imposition.occupants.build(
        nom: declarant[:nom],
        prenom: declarant[:prenom],
        date_de_naissance: "#{declarant[:date_de_naissance]}",
        declarant: true,
        demandeur: false
      )
    end

    contribuable.nombre_personnes_charge.times do |index|
      avis_imposition.occupants.build(
        nom:    "#{declarant_count + index + 1}",
        prenom: "Occupant ",
        date_de_naissance: nil,
        declarant: false,
        demandeur: false
      )
    end

    avis_imposition
  end

  def precise_adresse(adresse, previous_value: nil, required: false)
    if adresse.blank?
      if required
        raise I18n.t('demarrage_projet.demandeur.erreurs.adresse_vide')
      else
        return nil
      end
    end

    if previous_value && adresse == previous_value.description
      return previous_value
    end

    adresse_localisee = @service_adresse.precise(adresse)
    if !adresse_localisee
      raise I18n.t('demarrage_projet.demandeur.erreurs.adresse_inconnue')
    end

    adresse_localisee
  end

private

  def logger
    Rails.logger
  end
end
