class ApplicationController < ActionController::Base
  include ApplicationHelper

  layout 'logged_in'

  protect_from_forgery with: :exception

  def authentifie_sans_redirection
    if agent_signed_in?
      @role_utilisateur = :agent
    elsif @role_utilisateur.blank?
      @role_utilisateur = :demandeur
      if @projet_courant
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

  # Demandeurs access their projects through '/projets/' URLs;
  # Intervenants access their projects through '/dossiers/' URLs.
  def projet_or_dossier
    @projet_or_dossier = current_agent ? "dossier" : "projet"
  end

  # Expose a `projet_or_dossier_*_path` helper, which will dynamically
  # resolve to either `projet_*_path` or `dossier_*_path`, depending
  # of the currently connected user (demandeur or intervenant).
  #
  # The helper is available to both controllers and views.
  def self.expose_routing_helper(name)
    define_method name do |*args|
      resolved_name = name.to_s.sub(/projet_or_dossier/, projet_or_dossier)
      send(resolved_name, *args)
    end
    # Expose the helper to the views
    helper_method name
  end

  expose_routing_helper :projet_or_dossier_path
  expose_routing_helper :projet_or_dossier_proposition_path
  expose_routing_helper :projet_or_dossier_commentaires_path
  expose_routing_helper :projet_or_dossier_avis_impositions_path
  expose_routing_helper :projet_or_dossier_avis_imposition_path
  expose_routing_helper :new_projet_or_dossier_avis_imposition_path
  expose_routing_helper :projet_or_dossier_occupants_path
  expose_routing_helper :projet_or_dossier_occupant_path
end
