class ProjetConstructeur

  def initialize(service, service_adresse)
    @service = service
    @service_adresse = service_adresse
  end

  def initialise_projet(numero_fiscal, reference_avis)
    projet = Projet.new


    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)

    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal

    projet.nb_occupants_a_charge = contribuable.nombre_personnes_charge

    adresse = @service_adresse.precise(contribuable.adresse)
    projet.longitude = adresse[:longitude]
    projet.latitude = adresse[:latitude]
    projet.departement = adresse[:departement]
    projet.adresse_ligne1 = adresse[:adresse_ligne1]
    projet.code_insee = adresse[:code_insee]
    projet.code_postal = adresse[:code_postal]
    projet.ville = adresse[:ville]

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

end
