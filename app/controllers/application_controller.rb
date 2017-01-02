class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authentifie

  def authentifie
    jeton = params[:jeton] || session[:jeton]
    if jeton
      session[:jeton] = jeton
      @role_utilisateur = :intervenant
      invitation = Invitation.find_by_token(jeton)
      intervenant = invitation.intervenant
      projet = invitation.projet
      if invitation && (projet.prospect? || intervenant == projet.operateur || intervenant.instructeur?)
        @projet_courant = projet
        @utilisateur_courant = intervenant
      else
        utilisateur_invalide = true
      end
    elsif agent_signed_in?
      @role_utilisateur = :intervenant
      projet_id = params[:projet_id] || params[:id]
      @projet_courant = Projet.find(projet_id)
      @utilisateur_courant = current_agent
    else
      @role_utilisateur = :demandeur
      projet_id = params[:projet_id] || params[:id]
      @projet_courant = Projet.find(projet_id)
      @utilisateur_courant = @projet_courant.demandeur_principal
      utilisateur_invalide = true if session[:numero_fiscal] != @projet_courant.numero_fiscal
    end

    redirect_to new_session_path, alert: t('sessions.access_forbidden') if utilisateur_invalide
  end

  def after_sign_in_path_for(resource)
    if projet_id = session[:projet_id_from_opal]
      projet_path(Projet.find(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end
end

module CASClient
  module XmlResponse
    alias :check_and_parse_xml_normally :check_and_parse_xml
    def check_and_parse_xml(raw_xml)
      cooked_xml = raw_xml.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      check_and_parse_xml_normally(cooked_xml)
    end
  end
end
