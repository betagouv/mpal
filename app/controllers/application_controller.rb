class ApplicationController < ActionController::Base
  include ApplicationHelper

  layout 'logged_in'

  protect_from_forgery with: :exception

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
      projet_or_dossier_path(Projet.find_by_id(projet_id))
    else
      stored_location_for(resource) || root_path
    end
  end

  def current_ability
    #TODO add user management?
    @current_ability ||= Ability.new(current_agent)
  end

  def assert_projet_courant
    if current_agent
      @projet_courant = Projet.find_by_locator(params[:dossier_id]) if params[:dossier_id]
      unless @projet_courant && @projet_courant.accessible_for_agent?(current_agent)
        return redirect_to dossiers_path, alert: t('sessions.access_forbidden')
      end
    else
      @projet_courant = Projet.find_by_locator(params[:projet_id]) if params[:projet_id]
      unless @projet_courant
        return redirect_to root_path, alert: t('sessions.access_forbidden')
      end
    end
    if @projet_courant
      @page_heading = "Dossier : #{I18n.t(@projet_courant.statut, scope: "projets.statut").downcase}"
    end
    true
  end

  # Routing ------------------------

  def projet_or_dossier
    @projet_or_dossier = current_agent ? "dossier" : "projet"
  end

  def assert_projet_or_dossier_defined
    if @projet_or_dossier.blank?
      raise "`@projet_or_dossier` must be defined"
    end
  end

  def projet_or_dossier_path(projet)
    assert_projet_or_dossier_defined
    send("#{@projet_or_dossier}_path", projet)
  end
  helper_method :projet_or_dossier_path

  def projet_or_dossier_proposition_path(projet)
    assert_projet_or_dossier_defined
    send("#{@projet_or_dossier}_proposition_path", projet)
  end
  helper_method :projet_or_dossier_proposition_path

  def projet_or_dossier_commentaires_path(projet)
    assert_projet_or_dossier_defined
    send("#{@projet_or_dossier}_commentaires_path", projet)
  end
  helper_method :projet_or_dossier_commentaires_path

  def projet_or_dossier_avis_impositions_path(projet)
    assert_projet_or_dossier_defined
    send("#{@projet_or_dossier}_avis_impositions_path", projet)
  end
  helper_method :projet_or_dossier_avis_impositions_path

  def new_projet_or_dossier_avis_imposition_path(projet)
    assert_projet_or_dossier_defined
    send("new_#{@projet_or_dossier}_avis_imposition_path", projet)
  end
  helper_method :new_projet_or_dossier_avis_imposition_path
end
