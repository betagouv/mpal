class ApplicationController < ActionController::Base
  layout 'logged_in'

  protect_from_forgery with: :exception
  before_action :authentifie

  def authentifie_sans_redirection
    jeton = params[:jeton] || session[:jeton]
    if jeton
      session[:jeton] = jeton
      @role_utilisateur = :intervenant
      invitation = Invitation.find_by_token(jeton)
      if invitation
        intervenant = invitation.intervenant
        projet = invitation.projet
      end
      if invitation && (projet.prospect? || intervenant == projet.operateur || intervenant.instructeur?)
        @projet_courant = projet
        @utilisateur_courant = intervenant
      else
        @utilisateur_invalide = true
      end
    elsif agent_signed_in?
      @role_utilisateur = :agent
      projet_id = params[:projet_id] || params[:id]
      @projet_courant = Projet.find_by_id(projet_id)
      @utilisateur_courant = current_agent
    else
      @role_utilisateur = :demandeur
      projet_id = params[:projet_id] || params[:id]
      @projet_courant = Projet.find_by_id(projet_id)
      if @projet_courant
        @utilisateur_courant = @projet_courant.demandeur_principal
        @utilisateur_invalide = true if session[:numero_fiscal] != @projet_courant.numero_fiscal
      end
    end
    true
  end

  def authentifie
    authentifie_sans_redirection
    if @utilisateur_invalide
      return redirect_to new_session_path, alert: t('sessions.access_forbidden')
    end
    true
  end

  def after_sign_in_path_for(resource)
    if projet_id = session[:projet_id_from_opal]
      projet_path(Projet.find(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end
end
