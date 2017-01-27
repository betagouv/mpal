class ApplicationController < ActionController::Base
  layout 'logged_in'

  protect_from_forgery with: :exception
  before_action :dossier_ou_projet
  before_action :set_projet
  before_action :authentifie

  def authentifie_sans_redirection
    if agent_signed_in?
      @role_utilisateur = :agent
      @utilisateur_courant = current_agent
    elsif @role_utilisateur.blank?
      @role_utilisateur = :demandeur
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
      send("#{@dossier_ou_projet}_path", Projet.find_by_id(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end

  def dossier_ou_projet
    @dossier_ou_projet = current_agent ? "dossier" : "projet"
  end

  def set_projet
    projet_id = params[:dossier_id] || params[:projet_id] || params[:id]
    @projet_courant = Projet.find_by_id(projet_id) if projet_id
  end
end
