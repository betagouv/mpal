class DossiersController < ApplicationController
  #TODO vérifier l'authentification et le besoin du skip
  skip_before_action :authentifie, only: [:show]

  def index
    @invitations = @utilisateur_courant.intervenant.invitations
    @page_heading = "Dossiers"
  end

  def show
    numero_plateforme = params[:numero_plateforme]
    attributs = numero_plateforme.split('_')
    projet_id = attributs[0]
    plateforme_id = attributs[1]
    projet = Projet.where(id: projet_id, plateforme_id: plateforme_id).first
    if agent_signed_in?
      redirect_to projet_path(projet)
    else
      session[:projet_id_from_opal] = projet.id
      redirect_to new_agent_session_path
    end
  end
end
