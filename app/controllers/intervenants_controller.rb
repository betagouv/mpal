class IntervenantsController < ApplicationController

  before_action :assert_projet_courant
  authorize_resource :class => false

  def index
    @page_heading = "Contacts"
    eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse
    fetch_pris
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

private
  def fetch_pris
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      @pris        = @eligible ? rod_response.pris : rod_response.pris_eie
    else
      @pris        = @projet_courant.intervenants_disponibles(role: :pris).first
    end
  end
end
