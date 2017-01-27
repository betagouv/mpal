class DossiersController < ApplicationController
  include ProjetConcern

  skip_before_action :authentifie
  before_action :authenticate_agent!

  def affecter_agent
    if @projet_courant.agent
      return redirect_to dossier_path(@projet_courant), alert: t('projets.agent_deja_affecte')
    end
    @projet_courant.agent = current_agent
    unless @projet_courant.save
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to dossier_path(@projet_courant)
  end

  def index
    @dossiers = Projet.for_agent(current_agent)
    @page_heading = "Dossiers"
  end
end
