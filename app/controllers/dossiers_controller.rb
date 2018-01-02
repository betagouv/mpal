class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties

  before_action :authenticate_agent!
  before_action :assert_projet_courant, except: [:index, :home, :indicateurs]
  load_and_authorize_resource class: "Projet"
  skip_load_and_authorize_resource only: [:index, :home, :indicateurs, :update_api_particulier]

  def affecter_agent
    if @projet_courant.update_attribute(:agent, current_agent)
      flash[:notice] = t('projets.visualisation.projet_affecte')
    else
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to dossier_path(@projet_courant)
  end

  def list_department_intervenants
    departement_intervenants = fetch_departement_intervenants(@projet_courant).with_indifferent_access
    @departement_operateurs = departement_intervenants["operateurs"]
    @departement_instructeurs = departement_intervenants["service_instructeur"]
    @departement_pris_anah = departement_intervenants["pris_anah"]
  end

  def update_project_intervenants
    #ATTENTION : FAUT-IL PARFOIS CREER UN NOUVEL INTERVENANT ?
    @checked_intervenants_clavis_ids = intervenants_params
    if @checked_intervenants_clavis_ids.nil?
      @projet_courant.invitations.each{|invitation| invitation.destroy}
    else
      @intervenant_tab = []
      find_checked_intervenants
      add_invitations_when_checked
      delete_invitations_when_unchecked
    end
    message = I18n.t("admin.rod.valider_selection_intervenant_success")
    redirect_to(dossier_path(@projet_courant), flash: { success: message })

    #TODO cas: opérations programmées, attention pris suggested operateurs, contacted operateurs etc
    # gérer l'envoi de mails
  end

  def home
    if render_index
      @page_heading = "Accueil"
    end
  end

  def index
    if render_index
      @page_full_width = true
      @page_heading = I18n.t('tableau_de_bord.titre_section')
      render "dashboard"
    end
  end

  def indicateurs
    @page_heading = 'Indicateurs'

    unless current_agent.dreal? || current_agent.instructeur? || current_agent.siege?
      redirect_to dossiers_path, alert: t('sessions.access_forbidden')
    end

    if current_agent.siege?
      projets = Projet.all
    elsif (current_agent.dreal? || current_agent.instructeur?) && current_agent.intervenant.try(:departements).present?
      departements = current_agent.intervenant.try(:departements) || []
      #TODO Optimiser le Projet.all
      projets = departements.map { |d| Projet.all.select { |p| p.adresse.try(:departement) == d } }.flatten
    else
      projets = current_agent.intervenant.try(:projets) || []
    end

    @projets_count = projets.count
    all_projets_status = projets.map(&:status_for_intervenant)
    status_count = Projet::INTERVENANT_STATUSES.map { |s| all_projets_status.count(s) }
    @status_with_count = Projet::INTERVENANT_STATUSES.zip(status_count).to_h
  end

  def proposer
    @projet_courant.statut = :proposition_proposee
    if @projet_courant.save(context: :proposition)
      message = I18n.t('notification_validation_dossier.succes',
                       demandeur: @projet_courant.demandeur.fullname)
      ProjetMailer.notification_validation_dossier(@projet_courant).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'validation_proposition', projet: @projet_courant, producteur: @projet_courant.operateur)
      redirect_to projet_or_dossier_path(@projet_courant), notice: message
    else
      @projet_courant.restore_statut!
      render_proposition
    end
  end

  def proposition
    if @projet_courant.prospect?
      return redirect_to projet_or_dossier_path(@projet_courant), alert: t('sessions.access_forbidden')
    end
    if request.put?
      @projet_courant.statut = :proposition_enregistree
      if @projet_courant.update_attributes(projet_params)
        return redirect_to projet_or_dossier_path(@projet_courant), notice: t('projets.edition_projet.messages.succes')
      else
        flash.now[:alert] = t('projets.edition_projet.messages.erreur')
      end
    end
    render_proposition
  end

  def recommander_operateurs
    @page_heading = "Proposer des opérateurs"
    if request.post?
      begin
        if @projet_courant.suggest_operateurs!(suggested_operateurs_params[:suggested_operateur_ids])
          message = I18n.t("recommander_operateurs.succes",
          count:     @projet_courant.pris_suggested_operateurs.count,
          demandeur: @projet_courant.demandeur.fullname)
          redirect_to(dossier_path(@projet_courant), flash: { success: message })
        end
      rescue => e
        logger.error e.message
        redirect_to dossier_path(@projet_courant), alert: "Une erreur s’est produite lors de la proposition : le demandeur s’est engagé avec un opérateur"
      end
    end

    @available_operateurs = fetch_operateurs.to_a
    if @projet_courant.pris_suggested_operateurs.blank? && !request.post?
      @available_operateurs.shuffle!
    end
  end

  def show
    list_department_intervenants
    if Time.now.strftime("%Y").to_i - @projet_courant.avis_impositions.first.annee.to_i >= 2 && current_agent.operateur? == true && @projet_courant.date_depot == nil
      flash.now[:notice] = "Veuillez modifier le RFR (cumulé) de ce dossier et indiquer la référence du(des) nouvel(eaux) avis dans les champs libres de la synthèse du dossier."
    end
    render_show
  end

  def update_api_particulier
    if current_agent.admin?
      begin
        project = Projet.find_by_id(params[:project_id])
        old = []
        old.replace(project.avis_impositions)
        project.reset_fiscal_information
      rescue
        render :json => {:status => 2} and return
      end
      render :json => {:status => 0, :old => old, :avis => project.avis_impositions} and return
    end

    render :json => {:status => 1} and return
  end

  private
  def assign_projet_if_needed
    if !@projet_courant.agent_operateur && current_agent
      if @projet_courant.update_attribute(:agent_operateur, current_agent)
        flash.now[:notice] = t('projets.visualisation.projet_affecte')
      end
    end
  end

  def clean_projet_aides(attributes)
    if attributes[:projet_aides_attributes].present?
      attributes[:projet_aides_attributes].values.each do |projet_aide|
        projet_aide_to_modify = ProjetAide.where(aide_id: projet_aide[:aide_id], projet_id: @projet_courant.id).first
        projet_aide[:id] = projet_aide_to_modify.try(:id)
        amount = projet_aide[:localized_amount]
        projet_aide[:_destroy] = true if amount.blank? || BigDecimal(amount) == 0
      end
    end
    attributes
  end

  def clean_prestation_choices(attributes)
    if attributes[:prestation_choices_attributes].present?
      attributes[:prestation_choices_attributes].values.each do |prestation_choice|
        prestation_choice_to_modify = PrestationChoice.where(prestation_id: prestation_choice[:prestation_id], projet_id: @projet_courant.id).first
        prestation_choice[:id] = prestation_choice_to_modify.try(:id)
        if [:desired, :recommended, :selected].any? { |key| prestation_choice.key? key }
          fill_blank_values_with_false(prestation_choice)
        else
          prestation_choice[:_destroy] = true
        end
      end
    end
    attributes
  end

  def export_filename
    "dossiers_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.csv"
  end

  def fetch_operateurs
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      rod_response.operateurs
    else
      @projet_courant.intervenants_disponibles(role: :operateur)
    end
  end

  def fill_blank_values_with_false(prestation_choice)
    prestation_choice[:desired]     = prestation_choice[:desired].present?
    prestation_choice[:recommended] = prestation_choice[:recommended].present?
    prestation_choice[:selected]    = prestation_choice[:selected].present?
    prestation_choice
  end

  def projet_params
    attributes = params.require(:projet).permit(
        :disponibilite, :description, :email, :tel, :date_de_visite,
        :type_logement, :etage, :nb_pieces, :surface_habitable, :etiquette_avant_travaux,
        :niveau_gir, :autonomie, :handicap, :demandeur_salarie, :entreprise_plus_10_personnes,
        :note_degradation, :note_insalubrite, :ventilation_adaptee, :presence_humidite, :auto_rehabilitation,
        :remarques_diagnostic,
        :consommation_avant_travaux, :consommation_apres_travaux,
        :etiquette_avant_travaux, :etiquette_apres_travaux,
        :gain_energetique,
        :precisions_travaux, :precisions_financement,
        :localized_amo_amount, :localized_assiette_subventionnable_amount, :localized_maitrise_oeuvre_amount, :localized_travaux_ht_amount, :localized_travaux_ttc_amount,
        :localized_loan_amount, :localized_personal_funding_amount,
        :documents_attributes,
        :demande_attributes => [:id, :annee_construction],
        :theme_ids => [],
        :suggested_operateur_ids => [],
        :prestation_choices_attributes => [:prestation_id, :desired, :recommended, :selected],
        :projet_aides_attributes => [:aide_id, :localized_amount]
    )
    clean_projet_aides(attributes)
    clean_prestation_choices(attributes)
    attributes
  end

  def render_index
    params.permit(:page, :per_page, search: [:query, :status, :sort_by])
    search = params[:search] || {}
    page = params[:page]
    per_page = params[:per_page]

    respond_to do |format|
      format.html {
        if current_agent.admin?
          @dossiers = Projet.all.for_sort_by(search[:sort_by]).includes(:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant]).paginate(page: page, per_page: per_page)
          if search.present?
            @dossiers = @dossiers.for_text(search[:query]).for_intervenant_status(search[:status])
          end
        elsif current_agent.dreal?
          @dossiers = current_agent.intervenant.projets.paginate(page: page, per_page: per_page)
        elsif current_agent.siege?
          @dossiers = Projet.with_demandeur.for_sort_by(search[:sort_by]).includes(:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant]).paginate(page: page, per_page: per_page)
          if search.present?
            @dossiers = @dossiers.for_text(search[:query]).for_intervenant_status(search[:status])
          end
        else
          @invitations = Invitation.for_sort_by(search[:sort_by]).includes(projet: [:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant]]).paginate(page: page, per_page: per_page)
          if search.present?
            @invitations = @invitations.for_text(search[:query]).for_intervenant_status(search[:status])
          end
          if current_agent.operateur?
            @invitations = @invitations.visible_for_operateur(current_agent.intervenant)
          else
            @invitations = @invitations.where(intervenant_id: current_agent.intervenant_id)
          end
        end
        @statuses = Projet::INTERVENANT_STATUSES.inject([["", ""]]) { |acc, x| acc << [I18n.t("projets.statut.#{x}"), x] }
        @sort_by_options = Projet::SORT_BY_OPTIONS.map { |x| [I18n.t("projets.sort_by_options.#{x}"), x] }
      }
      format.csv {
        if current_agent.admin?
          @dossiers = Projet.all.for_sort_by(search[:sort_by]).includes(:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant])
          if search.present?
            @dossiers = @dossiers.for_text(search[:query]).for_intervenant_status(search[:status])
          end
          @selected_projects = @dossiers
        elsif current_agent.siege?
          @dossiers = Projet.with_demandeur.for_sort_by(search[:sort_by]).includes(:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant])
          if search.present?
            @dossiers = @dossiers.for_text(search[:query]).for_intervenant_status(search[:status])
          end
          @selected_projects = @dossiers
        elsif current_agent.dreal?
          @dossiers = current_agent.intervenant.projets
          @selected_projects = @dossiers
        else
          @invitations = Invitation.for_sort_by(search[:sort_by]).includes(projet: [:adresse_postale, :adresse_a_renover, :avis_impositions, :agents_projets, :messages, :payments, :themes, invitations: [:intervenant]])
          if search.present?
            @invitations = @invitations.for_text(search[:query]).for_intervenant_status(search[:status])
          end
          if current_agent.operateur?
            @invitations = @invitations.visible_for_operateur(current_agent.intervenant)
          else
            @invitations = @invitations.where(intervenant_id: current_agent.intervenant_id)
          end
          @selected_projects = @invitations.map{ |invitation| invitation.projet }
        end
        response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
        response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
        if current_agent.admin?
          render plain: Projet.to_csv(current_agent, @selected_projects, true)
        else
          render plain: Projet.to_csv(current_agent, @selected_projects, false)
        end
        return false
      }
    end
    true
  end

  def render_proposition
    assign_projet_if_needed

    aids = @projet_courant.aids_with_amounts
    @public_aids_with_amounts = aids.try(:public_assistance)
    @private_aids_with_amounts = aids.try(:not_public_assistance)

    @themes = Theme.ordered.all
    unless @projet_courant.projet_aides.any?
      Aide.active_for_projet(@projet_courant).ordered.each do |aide|
        @projet_courant.projet_aides.build(aide: aide)
      end
    end
    @page_heading = "Projet proposé par l’opérateur"
    render "projets/proposition"
  end

  def suggested_operateurs_params
    attributes = params
      .fetch(:projet, {})
      .permit(:suggested_operateur_ids => [])
    attributes[:suggested_operateur_ids] ||= []
    attributes
  end

  #update_project_intervenants methods
  def add_invitations_when_checked
    @intervenant_tab.each do |intervenant|
      unless @projet_courant.intervenants.include?(intervenant) then
        if intervenant.pris?
          invitation = @projet_courant.invite_pris!(intervenant)
          Projet.notify_intervenant_of(invitation)
          invitation.save
        elsif intervenant.operateur?
          @projet_courant.suggest_operateurs!([intervenant.id])
        else
          invitation = Invitation.new(projet_id: @projet_courant.id, intervenant_id: intervenant.id, suggested: false, contacted: false)
          invitation.save
        end
        #faire popper erreur
      end
    end
  end

  def delete_invitations_when_unchecked
    @projet_courant.invitations.each do |invitation|
      invitation_has_intervenant = []
      @intervenant_tab.each do |intervenant|
        if invitation.intervenant_id == intervenant.id
          invitation_has_intervenant.append(invitation)
        end
      end
      if !invitation_has_intervenant.include?(invitation)
        invitation.destroy
      end
    end
  end

  def fetch_departement_intervenants(projet)
    if ENV['ROD_ENABLED'] == 'true'
      Rod.new(RodClient).list_intervenants_rod(projet.adresse.departement)
    else
      Fakeweb::Rod::FakeResponseList
    end
  end

  def find_checked_intervenants
    @checked_intervenants_clavis_ids.each do |clavis_id|
      intervenant = Intervenant.find_by_clavis_service_id(clavis_id)
      @intervenant_tab.append(intervenant)
    end
  end

  def intervenants_params
    intervenants_params = (params["pris_ids"] || Array.new) +
    (params["operateur_ids"] || Array.new) +
    (params["instructeur_ids"] || Array.new)
    intervenants_params&.delete("on")
    intervenants_params
  end
end
