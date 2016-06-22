class ProjetFacade
  def initialize(service, service_adresse)
    @service = service
    @service_adresse = service_adresse
  end

  def initialise_projet(numero_fiscal, reference_avis)
    projet = Projet.new

    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)
    projet.usager = contribuable.usager
    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal

    adresse = @service_adresse.precise(contribuable.adresse)
    projet.longitude = adresse[:longitude]
    projet.latitude = adresse[:latitude]
    projet.departement = adresse[:departement]
    projet.adresse = adresse[:adresse]
    projet
  end

end
