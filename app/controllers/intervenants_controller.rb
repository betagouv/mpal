class IntervenantsController < ApplicationController

  before_action :assert_projet_courant
  authorize_resource :class => false

  def index
    @page_heading = "Liste de contacts"
    @pris = @projet_courant.invited_pris
    @operateur = @projet_courant.operateur
    @instructeur = @projet_courant.invited_instructeur
    @demandeur = @projet_courant.demandeur
    @personne = @projet_courant.personne
    if @personne && @personne.civilite == "mrs"
      @civilite = "Madame"
    else
      @civilite = "Monsieur"
    end
  end 
end
