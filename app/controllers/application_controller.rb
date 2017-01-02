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
      puts " --- CURRENT AGENT -- #{current_agent.username}"
      puts " --- CURRENT PROJET -- #{@projet_courant.id}"
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

def email_valide?(email)
  email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i) || email.empty?
end

def projet_valide?
  @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
  @projet_courant.errors[:email] = t('projets.edition_projet.messages.erreur_email_invalide') unless email_valide?(@projet_courant.email)
  @projet_courant.adresse.present? && email_valide?(@projet_courant.email)
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
