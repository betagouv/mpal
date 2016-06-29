class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authentifie

  def authentifie
    if params[:jeton]  # appelé par un intervenant
      @role_utilisateur = :intervenant
      invitation = Invitation.find_by_token(params[:jeton])
      if invitation
        @projet_courant = invitation.projet
        @utilisateur_courant = invitation.intervenant
      else
        utilisateur_invalide = true 
      end
    else
      @role_utilisateur = :demandeur
      projet_id = params[:id] || params[:projet_id]
      @projet_courant = Projet.find(projet_id)
      @utilisateur_courant = @projet_courant.demandeur_principal
      utilisateur_invalide = true if session[:numero_fiscal] != @projet_courant.numero_fiscal
    end

    redirect_to new_session_path, alert: t('sessions.access_forbidden') if utilisateur_invalide
  end
end
