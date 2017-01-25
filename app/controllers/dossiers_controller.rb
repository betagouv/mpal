class DossiersController < ApplicationController
  include ProjetConcern

  skip_before_action :authentifie
  before_action :dossier_ou_projet
  before_action :authenticate_agent!

  def affecter_agent
    if @projet_courant.agent
      return redirect_to projet_path(@projet_courant), alert: t('projets.agent_deja_affecte')
    end
    @projet_courant.agent = @utilisateur_courant
    unless @projet_courant.save
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to projet_path(@projet_courant)
  end

  def index
    @dossiers = Projet.for_agent(current_agent)
    @page_heading = "Dossiers"
  end

private
  def dossier_ou_projet
    @dossier_ou_projet = "dossier"
  end
end
