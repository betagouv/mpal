class ProjetFacade
  def initialize(service)
    @service = service
  end

  def initialise_projet(numero_fiscal, reference_avis)
    projet = Projet.new
    contribuable = @service.retrouve_contribuable(numero_fiscal, reference_avis)
    projet.usager = contribuable.usager
    projet.reference_avis = reference_avis
    projet.numero_fiscal = numero_fiscal
    projet.adresse = contribuable.adresse
    projet
  end

  def self.recupere_projet(numero_fiscal)
    projet = Projet.where(numero_fiscal: numero_fiscal).first
  end
end
