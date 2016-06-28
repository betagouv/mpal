class ProjetFacade
  def initialize(service, service_adresse)
    @service = service
    @service_adresse = service_adresse
  end

  def initialise_projet(numero_fiscal, reference_avis)
    projet = Projet.new

    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)
    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal

    adresse = @service_adresse.precise(contribuable.adresse)
    projet.longitude = adresse[:longitude]
    projet.latitude = adresse[:latitude]
    projet.departement = adresse[:departement]
    projet.adresse = adresse[:adresse]

    contribuable.declarants.each do |declarant|
      projet.occupants.build(
        nom: declarant[:nom], prenom: declarant[:prenom],
        date_de_naissance: "#{declarant[:date_de_naissance]}",
        demandeur: true)
    end
    projet
  end

end
