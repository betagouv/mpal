class ProjetInitializer
  def initialize(service_particulier = nil, service_adresse = nil)
    @service_particulier = service_particulier || ApiParticulier.new
    @service_adresse = service_adresse || ApiBan.new
  end

  def initialize_projet(numero_fiscal, reference_avis)
    projet = Projet.new

    contribuable = @service_particulier.retrouve_contribuable(numero_fiscal, reference_avis)

    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal
    projet.nb_occupants_a_charge = contribuable.nombre_personnes_charge

    begin
      projet.adresse_postale = self.precise_adresse(contribuable.adresse)
    rescue => e
      logger.info "ProjetInitializer: l'adresse n'a pas pu être localisée (#{e})"
    end

    contribuable.declarants.each do |declarant|
      projet.occupants.build(
        nom: declarant[:nom], prenom: declarant[:prenom],
        date_de_naissance: "#{declarant[:date_de_naissance]}",
        demandeur: true)
    end

    avis_imposition = projet.avis_impositions.build
    avis_imposition.reference_avis = reference_avis
    avis_imposition.numero_fiscal = numero_fiscal
    avis_imposition.annee = contribuable.annee_impots
    avis_imposition.declarant_1 = "#{contribuable.declarants[0][:prenom]} #{contribuable.declarants[0][:nom]}"
    avis_imposition.declarant_2 = "#{contribuable.declarants[1][:prenom]} #{contribuable.declarants[1][:nom]}" if contribuable.declarants[1].present?
    avis_imposition.nombre_personnes_charge = contribuable.nombre_personnes_charge

    projet
  end

  def precise_adresse(adresse, previous_value: nil, required: false)
    if adresse.blank?
      if required
        raise I18n.t('demarrage_projet.etape1_demarrage_projet.erreurs.adresse_vide')
      else
        return nil
      end
    end

    if previous_value && adresse == previous_value.description
      return previous_value
    end

    adresse_localisee = @service_adresse.precise(adresse)
    if !adresse_localisee
      raise I18n.t('demarrage_projet.etape1_demarrage_projet.erreurs.adresse_inconnue')
    end

    adresse_localisee
  end

private

  def logger
    Rails.logger
  end
end
