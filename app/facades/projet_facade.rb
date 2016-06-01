class ProjetFacade
  def initialize(service)
    @service = service
  end

  def initialise_projet(numero_fiscal, reference_avis, description)
    @projet = Projet.new
    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)
    @projet.adresse = contribuable.adresse
    @projet.usager = contribuable.usager
    @projet.description = description
    @projet.reference_avis = reference_avis
    @projet.numero_fiscal = numero_fiscal
    @projet
  end
end
