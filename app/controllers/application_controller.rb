class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authentifie

  def authentifie
    jeton = params[:jeton] || session[:jeton]
    if jeton
      session[:jeton] = jeton
      @role_utilisateur = :intervenant
      invitation = Invitation.find_by_token(jeton)
      if invitation
        @projet_courant = invitation.projet
        @utilisateur_courant = invitation.intervenant
      else
        utilisateur_invalide = true
      end
    else
      @role_utilisateur = :demandeur
      projet_id = params[:projet_id] || params[:id]
      @projet_courant = Projet.find(projet_id)
      @utilisateur_courant = @projet_courant.demandeur_principal
      utilisateur_invalide = true if session[:numero_fiscal] != @projet_courant.numero_fiscal
    end

    redirect_to new_session_path, alert: t('sessions.access_forbidden') if utilisateur_invalide
  end
end

module CASClient
  module XmlResponse
    alias_method :check_and_parse_xml_normally, :check_and_parse_xml
    def check_and_parse_xml(raw_xml)
      cooked_xml = raw_xml.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      check_and_parse_xml_normally(cooked_xml)
    end
  end
end
