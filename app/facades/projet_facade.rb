class ProjetFacade
  def initialize(service_particulier=ApiParticulier, params)
    particulier = service_particulier.new(params[:reference_avis], params[:numero_fiscal])
    @projet = Projet.new
    @projet.reference_avis = params[:reference_avis]
    @projet.numero_fiscal = params[:numero_fiscal]
    @projet.description = params[:description]
    @projet.adresse = particulier.address
    @projet.usager = particulier.owner
  end

  def projet
    @projet
  end
end
