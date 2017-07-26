module ApplicationConcern
  extend ActiveSupport::Concern

  included do
    layout "logged_in"

    def redirect_to_project_if_exists
      projet_or_dossier
      if current_user.try(:projet)
        if current_user.projet.invitations.blank?
          return redirect_to projet_mise_en_relation_path(current_user.projet)
        end
        return redirect_to projet_path(current_user.projet)
      elsif current_agent
        return redirect_to dossiers_path
      elsif session[:project_id]
        project = Projet.find_by_id(session[:project_id])
        if project
          return redirect_to projet_path(project)
        else
          session.delete :project_id
        end
      end
      true
    end

    def assert_projet_courant
      projet_or_dossier
      if current_user
        @projet_courant = current_user.projet
        if params[:projet_id] && params[:projet_id].to_i != @projet_courant.id
          return redirect_to controller: params[:controller], action: params[:action], projet_id: @projet_courant.id
        end
        # NOTE: user should have one project (at least); if not, let the drama begin…
      elsif current_agent
        @projet_courant = Projet.find_by_locator(params[:dossier_id])
      else
        @projet_courant = Projet.find_by_locator(session[:project_id])
        unless @projet_courant
          return redirect_to root_path, alert: t("sessions.access_forbidden")
        end
        if @projet_courant.user
          session.delete :project_id
          return redirect_to new_user_session_path, alert: t("sessions.user_exists")
        end
      end
      if @projet_courant
        @page_heading = "Dossier : #{I18n.t(@projet_courant.statut, scope: "projets.statut").downcase}"
      end
      true
    end

    # Routing ------------------------

    # Demandeurs access their projects through '/projets/' URLs;
    # Agents access their projects through '/dossiers/' URLs.
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
    expose_routing_helper :projet_or_dossier_demande_path
    expose_routing_helper :projet_or_dossier_payment_registry_path
    expose_routing_helper :ask_for_modification_projet_or_dossier_payment_path
    expose_routing_helper :ask_for_instruction_projet_or_dossier_payment_path
  end
end

