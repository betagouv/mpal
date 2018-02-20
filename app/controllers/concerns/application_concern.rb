module ApplicationConcern
  extend ActiveSupport::Concern

  included do
    layout "project"

    def redirect_to_project_if_exists
      return redirect_to dossiers_path if current_agent
      return redirect_to projets_path  if current_user.try(:mandataire?)

      if current_user.try(:demandeur?)
        projet = current_user.projet_as_demandeur
      elsif session[:project_id]
        projet = Projet.find_by_id(session[:project_id])
        if projet.blank?
          session.delete :project_id
          return projets_new_path
        end
      else
        return projets_new_path
      end

      return redirect_to projet_demandeur_path(projet)        if projet.max_registration_step == Projet::STEP_DEMANDEUR
      return redirect_to projet_avis_impositions_path(projet) if projet.max_registration_step == Projet::STEP_AVIS_IMPOSITIONS
      return redirect_to projet_occupants_path(projet)        if projet.max_registration_step == Projet::STEP_OCCUPANTS
      return redirect_to projet_demande_path(projet)          if projet.max_registration_step == Projet::STEP_DEMANDE
      return redirect_to projet_eligibility_path(projet)      if projet.max_registration_step == Projet::STEP_ELIGIBILITY
      return redirect_to projet_mise_en_relation_path(projet) if projet.max_registration_step == Projet::STEP_MISE_EN_RELATION && projet.invitations.blank?
      redirect_to projet_path(projet)
    end

    def assert_projet_courant
      projet_or_dossier
      if current_user
        #TODO why dossier_id ? (payment_registry)
        projet_requested = Projet.find_by_locator(params[:projet_id] || params[:dossier_id])
        @projet_courant = (current_user.projets.include? projet_requested) ? projet_requested : nil
        # NOTE: user should have one project (at least); if not, let the drama begin…
      elsif current_agent
        @projet_courant = Projet.find_by_locator(params[:dossier_id])
        if @projet_courant
          @projet_courant.mark_last_viewed_at!(current_agent)
        end
      else
        @projet_courant = Projet.find_by_locator(session[:project_id])
        unless @projet_courant
          return redirect_to root_path, alert: t("sessions.access_forbidden")
        end
        if @projet_courant.demandeur_user
          session.delete :project_id
          redirect_to new_user_session_path, alert: t("sessions.user_exists")
        end
      end
      if @projet_courant
        if @projet_courant.opal_position_label
          @page_heading = "Dossier: #{@projet_courant.opal_position_label}"
        else
          @page_heading = "Dossier : #{I18n.t(@projet_courant.statut, scope: "projets.statut").downcase}"
        end
      end
    end

    def set_current_registration_step step
      @current_registration_step = step
      if @projet_courant.max_registration_step < step
        @projet_courant.update(max_registration_step: step)
      end
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
    expose_routing_helper :projet_or_dossier_avis_impositions_path
    expose_routing_helper :projet_or_dossier_avis_imposition_path
    expose_routing_helper :new_projet_or_dossier_avis_imposition_path
    expose_routing_helper :projet_or_dossier_occupants_path
    expose_routing_helper :projet_or_dossier_occupant_path
    expose_routing_helper :projet_or_dossier_demande_path
    expose_routing_helper :new_projet_or_dossier_message_path
    expose_routing_helper :projet_or_dossier_messages_path
    expose_routing_helper :projet_or_dossier_payments_path
    expose_routing_helper :ask_for_modification_projet_or_dossier_payment_path
    expose_routing_helper :ask_for_instruction_projet_or_dossier_payment_path
    expose_routing_helper :projet_or_dossier_document_path
    expose_routing_helper :projet_or_dossier_documents_path
    expose_routing_helper :projet_or_dossier_intervenants_path
  end
end

