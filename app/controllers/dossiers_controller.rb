class DossiersController < ApplicationController
  include ProjetConcern

  skip_before_action :authentifie
  before_action :authenticate_agent!
  skip_before_action :assert_projet_courant, only: [:index]

  def affecter_agent
    if @projet_courant.update_attribute(:agent, current_agent)
      flash[:notice] = t('projets.visualisation.projet_affecte')
    else
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to dossier_path(@projet_courant)
  end

  def index
    @dossiers = Projet.for_agent(current_agent)
    @page_heading = "Dossiers"
  end
end
