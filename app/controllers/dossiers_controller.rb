class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties
  require 'will_paginate/array'

  before_action :authenticate_agent!
  before_action :assert_projet_courant, except: [:index, :home, :indicateurs]
  load_and_authorize_resource class: "Projet"
  skip_load_and_authorize_resource only: [:index, :home, :indicateurs, :update_api_particulier, :activate, :desactivate, :manage_eligibility, :confirm_eligibility, :ruby_rod]

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

  def ruby_rod
    projet = Projet.find(params[:id])
    if projet.admin_rod_button
      redirect_to(dossier_path(projet), flash: { success: t('admin.rod.valider_selection_intervenant_success') }) and return
    end
    redirect_to(dossier_path(projet), flash: { alert: "Vous ne pouvez pas effectuer cette action" }) and return
  end

  def home
    if render_index
      @page_full_width = true
      @page_heading = I18n.t('tableau_de_bord.titre_section')
      render "dashboard", :notice => flash and return
    end
    redirect_to root_path, alert: t('sessions.access_forbidden')
  end

  def index
    if render_index
      @page_full_width = true
      @page_heading = I18n.t('tableau_de_bord.titre_section')
      render "dashboard", :notice => flash
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
      if departements != []
        str = "(ift_adresses2.departement = '" + departements[0] + "' OR (ift_adresses1.departement =  '" + departements[0] + "' AND ift_adresses2 IS NULL))"
        departements.each_with_index do |d, i|
          if i > 0
            str += " OR (ift_adresses2.departement = '" + d + "' OR (ift_adresses1.departement = '" + d + "' AND ift_adresses2 IS NULL))"
          end
        end
        projets = Projet.joins("INNER JOIN adresses ift_adresses1 ON (projets.adresse_postale_id = ift_adresses1.id) LEFT OUTER JOIN adresses ift_adresses2 ON (projets.adresse_a_renover_id = ift_adresses2.id)").where(str)
      else
        projets = []
      end
    else
      projets = current_agent.intervenant.try(:projets) || []
    end

    @inactif = projets.where("actif = 0")
    @no_eligible = projets.where("eligibilite = 2")
    @no_eligible_reevaluer = projets.where("eligibilite = 1")
    @no_eligible_confirmer = projets.where("eligibilite = 4")
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
    annee = Time.now.strftime("%Y").to_i - @projet_courant.avis_impositions.first.annee.to_i
    if annee > 2 && current_agent.operateur? == true && @projet_courant.date_depot == nil
        flash.now[:notice] = "Veuillez modifier le RFR (cumulé) de ce dossier et indiquer la référence du(des) nouvel(eaux) avis dans les champs libres de la synthèse du dossier."
    end
    if annee == 2 and Time.now.strftime("%m").to_i >= 9
        flash.now[:notice] = "Veuillez modifier le RFR (cumulé) de ce dossier et indiquer la référence du(des) nouvel(eaux) avis dans les champs libres de la synthèse du dossier."
    end
    render_show
  end


  def manage_eligibility

  end

  def confirm_eligibility
    @projet_courant.reload
    commentaire = @projet_courant.eligibility_commentaire
    if params[:comment].present?
      commentaire += "<br>Commentaire de l'intervenant : <br>" + params[:comment]
    end
    if params[:response].present? && params[:response] == "situation_changed"
      @projet_courant.update(:eligibilite => 3, :eligibility_commentaire => commentaire)
    else
      @projet_courant.update(:eligibilite => 4, :eligibility_commentaire => commentaire)
    end
    redirect_to :action => :show and return
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




  def activate
    if current_agent
      begin
        projet = Projet.find(params[:dossier_id])
        projet.actif = 1
        projet.save
      rescue
        redirect_to "/dossiers", notice: "Une erreur est survenue." and return
        # render :json => {"parametre" => params, "projet" => projet} and return
      end
      redirect_to "/dossiers", notice: "Le projet a bien été activé" and return
      # render :json => {"parametre" => params, "projet" => projet} and return
    end
    redirect_to "/dossiers", notice: "Une erreur est survenue." and return
    # render :json => {"parametre" => params, "projet" => projet} and return
  end

  def desactivate
    if current_agent
      begin
        projet = Projet.find(params[:dossier_id])
        if projet.status_already(:transmis_pour_instruction)
          redirect_to "/dossiers", alert: "Une erreur est survenue." and return
          # render :json => {"parametre" => params, "projet" => projet} and return
        end
        projet.actif = 0
        projet.save
      rescue
        redirect_to "/dossiers", notice: "Une erreur est survenue." and return
      end
      redirect_to "/dossiers", notice: "Le projet a bien été désactivé" and return
      # render :json => {"parametre" => params, "projet" => projet} and return
    end
    redirect_to "/dossiers", notice: "Une erreur est survenue." and return
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

  def search_for_intervenant_status search, dossiers
      if search.present?
        dossiers = dossiers.for_text(search[:query]).for_intervenant_status(search[:status])
      end
      return dossiers
  end

  def render_csv search
    response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
    response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
    response.status = 200
    response.headers['X-Accel-Buffering'] = 'no'
    response.headers["Cache-Control"] ||= "no-cache"
    response.headers.delete("Content-Length")
    to_select = "projets.* , CONCAT(CONCAT(string_agg(DISTINCT demandeur.prenom, ''), ' '), string_agg(DISTINCT demandeur.nom, '')) as demandeur_fullname, array_to_string(ARRAY_AGG(DISTINCT ift_themes.libelle), ', ') as libelle_theme, COUNT(DISTINCT messages.id) as message_count, array_to_string(ARRAY_AGG(DISTINCT CONCAT(CONCAT(ift_payement.type_paiement, ' '), ift_payement.statut)), ' - ') as payement_status, string_agg(DISTINCT ift_adresse_postale.ville, '') as postale_ville, string_agg(DISTINCT ift_adresse_postale.departement, '') as postale_dep,  string_agg(DISTINCT ift_adresse_postale.region, '') as postale_region, string_agg(DISTINCT ift_adresse_a_renover.ville, '') as renov_ville, string_agg(DISTINCT ift_adresse_a_renover.departement, '') as renov_dep, string_agg(DISTINCT ift_adresse_a_renover.region, '') as renov_region, array_to_string(ARRAY_AGG(DISTINCT ift_intervenants1.raison_sociale), '') as ift_pris, array_to_string(ARRAY_AGG(DISTINCT ift_intervenants2.raison_sociale), '') as ift_operateur, array_to_string(ARRAY_AGG(DISTINCT ift_intervenants3.raison_sociale), '') as ift_instructeur, CONCAT(CONCAT(string_agg(DISTINCT ift_agent_instructeur.prenom, ''), ' '), string_agg(DISTINCT ift_agent_instructeur.nom, '')) as ift_agent_instructeur, CONCAT(CONCAT(string_agg(DISTINCT ift_agent_operateur.prenom, ''), ' '), string_agg(DISTINCT ift_agent_operateur.nom, ''))  as ift_agent_operateur"
    to_join = "INNER JOIN avis_impositions ift_avis_impositions ON (projets.id = ift_avis_impositions.projet_id) INNER JOIN occupants demandeur ON (ift_avis_impositions.id = demandeur.avis_imposition_id AND demandeur.demandeur = true) INNER JOIN adresses ift_adresse_postale ON (ift_adresse_postale.id = projets.adresse_postale_id) LEFT OUTER JOIN adresses ift_adresse_a_renover ON (ift_adresse_a_renover.id = projets.adresse_a_renover_id) LEFT OUTER JOIN payments ift_payement on ift_payement.projet_id = projets.id LEFT OUTER JOIN messages on messages.projet_id = projets.id LEFT OUTER JOIN invitations on projets.id = invitations.projet_id LEFT OUTER JOIN intervenants ON  invitations.intervenant_id = intervenants.id LEFT OUTER JOIN projets_themes ift_ptheme ON (projets.id = ift_ptheme.projet_id) LEFT OUTER JOIN themes ift_themes ON (ift_ptheme.theme_id = ift_themes.id) LEFT OUTER JOIN invitations ift_invitations ON (projets.id = ift_invitations.projet_id) LEFT OUTER JOIN intervenants ift_intervenants1 ON (ift_invitations.intervenant_id = ift_intervenants1.id AND 'pris' = ANY(ift_intervenants1.roles)) LEFT OUTER JOIN intervenants ift_intervenants2 ON (ift_invitations.intervenant_id = ift_intervenants2.id AND 'operateur' = ANY(ift_intervenants2.roles)) LEFT OUTER JOIN intervenants ift_intervenants3 ON (ift_invitations.intervenant_id = ift_intervenants3.id AND 'instructeur' = ANY(ift_intervenants3.roles)) LEFT OUTER JOIN agents ift_agent_operateur ON (projets.agent_operateur_id = ift_agent_operateur.id) LEFT OUTER JOIN agents ift_agent_instructeur ON (projets.agent_instructeur_id = ift_agent_instructeur.id)"
    if current_agent.admin?
      # @dossiers = Projet.all.for_sort_by(search[:sort_by])
      # @dossiers = search_for_intervenant_status(search, @dossiers).select(to_select).joins(to_join).group("projets.id")
      @dossiers, _, _, _, _ = Projet.all.search_dossier(search, to_select, to_join)
    elsif current_agent.siege?
      # @dossiers = Projet.with_demandeur.for_sort_by(search[:sort_by])
      # @dossiers = search_for_intervenant_status(search, @dossiers).select(to_select).joins(to_join).group("projets.id")
      @dossiers, _, _, _, _ = Projet.with_demandeur.search_dossier(search, to_select, to_join)
    elsif current_agent.dreal?
      # @dossiers = current_agent.intervenant.projets
      # @dossiers = @dossiers.select(to_select).joins(to_join).group("projets.id")
      @dossiers, _, _, _, _ = current_agent.intervenant.projets.search_dossier(search, to_select, to_join)
    else
      if current_agent.operateur?
        @dossiers = Projet.all.select(to_select).joins(to_join).where(["projets.operateur_id is NULL or projets.operateur_id = ?", current_agent.intervenant.id]).group("projets.id")
      else
        @dossiers = Projet.all.select(to_select).joins(to_join).where(["invitations.intervenant_id = ?", current_agent.intervenant_id]).group("projets.id")
      end
      # @dossiers = search_for_intervenant_status(search, @dossiers.for_sort_by(search[:sort_by]))
      @dossiers, _, _, _, _ = @dossiers.search_dossier(search, to_select, to_join)

    end
    self.response_body = Projet.to_csv(current_agent, @dossiers, current_agent.admin?)
    return false
  end

  def fill_deep_tab traited, action, verif, actif, message, dossier
    if traited
      @traited << dossier
    elsif action
      @action << dossier
    elsif verif
      @verif << dossier
    elsif actif
      @others << dossier
    else
      @inactifs << dossier
    end
    if message
      @new_msg << dossier
    end
  end

  def fill_tab_intervenant all
    flash.now[:notice_html] = ""


    if current_agent.pris?
      @traited = all.where("projets.actif = 1 and projets.statut >= 2 and projets.operateur_id is not NULL and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @action = all.where("projets.actif = 1 and projets.operateur_id is NULL and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @verif = all.where("projets.actif = 1 and projets.statut = 1 and projets.operateur_id is not NULL and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @others = []
      @new_msg = all.where.not("projets.statut >= 2 and projets.operateur_id is not NULL and (projets.eligibilite = 3 or projets.eligibilite = 0)").where("projets.actif = 1 and ift_agents_projets.last_read_messages_at < ift_messages.created_at")
      @rfrn2 = []
    elsif current_agent.operateur?
      @traited = all.where("projets.actif = 1 and projets.statut >= 5 and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @action = all.where("projets.actif = 1  and projets.statut < 3 and projets.statut >= 1 and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @verif = all.where("projets.actif = 1 and projets.statut = 3 and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @others = []
      @new_msg = all.where.not("projets.statut >= 5 and (projets.eligibilite = 3 or projets.eligibilite = 0)").where("projets.actif = 1 and ift_agents_projets.last_read_messages_at < ift_messages.created_at")
      @rfrn2 = all.where("ift_avis_impositions2.annee is not NULL")
      if @rfrn2.limit(1).present?
        flash.now[:notice_html] += "Certains dossiers nécessitent de mettre à jour le ou les avis d'imposition (dernier avis d'imposition ou avis de situation déclarative disponible) (voir onglet RFR N-2)"
      end
    elsif current_agent.instructeur?
      @traited = all.where("projets.actif = 1 and projets.statut >= 6 and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @action = all.where("projets.actif = 1 and projets.statut = 5 and (projets.eligibilite = 3 or projets.eligibilite = 0)")
      @verif = []
      @others = []
      @new_msg = all.where.not("projets.statut >= 6 and (projets.eligibilite = 3 or projets.eligibilite = 0)").where("projets.actif = 1 and ift_agents_projets.last_read_messages_at < ift_messages.created_at")
      @rfrn2 = []
    end
  end

def is_there_search? search
  return search[:query].present? || search[:status].present? || search[:sort_by].present? || search[:type].present? || search[:folder].present? || search[:tenant].present? || search[:location].present? || search[:interv].present? || search[:operation_programmee].present? || search[:from].present? || search[:to].present?
end

def render_index
    params.permit(:format, :page, :per_page, :page_noel, :page_noelre, :page_noelco, :page_rfrn2, :page_actif, :page_others, :page_new_msg, :page_verif, :page_action, :page_traited, search: [:query, :status, :sort_by, :type, :folder, :tenant, :location, :interv, :operation_programmee, :from, :to, :advanced, :activeTab])
    search = params[:search] || {}
    #numéro de la page
    page = params[:page] || 1
    page_traited = params[:page_traited] || 1
    page_action = params[:page_action] || 1
    page_verif = params[:page_verif] || 1
    page_new_msg = params[:page_new_msg] || 1
    page_others = params[:page_others] || 1
    page_inactifs = params[:page_inactifs] || 1
    page_noel = params[:page_noel] || 1
    page_noelre = params[:page_noelre] || 1
    page_noelco = params[:page_noelco] || 1
    page_rfrn2 = params[:page_rfrn2] || 1
    #nombre d'objet par page

    per_page = params[:per_page]  || 20

    respond_to do |format|
      format.html {
        all = []
        @dossiers = []
        @traited = []
        @action = []
        @verif = []
        @new_msg = []
        @others = []
        @actifs = []
        @inactifs = []
        @rfrn2 = []
        @non_eligible = []
        @non_eligible_a_reeval = []
        @non_eligible_confirm = []
        anne_var = (Time.now.strftime("%Y").to_i - 2).to_s
        month_var = (Time.now.strftime("%m").to_i).to_s
        to_select = "projets.*, string_agg(DISTINCT demandeur.prenom, '') as demandeur_prenom, string_agg(DISTINCT demandeur.nom, '') as demandeur_nom, array_to_string(ARRAY_AGG(DISTINCT ift_themes.libelle), ', ') as libelle_theme, string_agg(DISTINCT ift_adresse.ville, '') as addr_ville, string_agg(DISTINCT ift_adresse.code_postal, '') as addr_code, array_to_string(ARRAY_AGG(DISTINCT ift_intervenant.raison_sociale), ' / ') as ift_intervenant, CONCAT(CONCAT(string_agg(DISTINCT ift_agent.prenom, ''), ' '), string_agg(DISTINCT ift_agent.nom, '')) as ift_agent"
        to_join = "INNER JOIN avis_impositions ift_avis_impositions ON (projets.id = ift_avis_impositions.projet_id) INNER JOIN occupants demandeur ON (ift_avis_impositions.id = demandeur.avis_imposition_id AND demandeur.demandeur = true) INNER JOIN adresses ift_adresse ON (projets.adresse_a_renover_id = ift_adresse.id) OR (projets.adresse_postale_id = ift_adresse.id AND projets.adresse_a_renover_id is NULL)  LEFT OUTER JOIN invitations on projets.id = invitations.projet_id  LEFT OUTER JOIN intervenants ON  invitations.intervenant_id = intervenants.id  LEFT OUTER JOIN projets_themes ift_ptheme ON (projets.id = ift_ptheme.projet_id)  LEFT OUTER JOIN themes ift_themes ON (ift_ptheme.theme_id = ift_themes.id)  LEFT OUTER JOIN invitations ift_invitations ON (projets.id = ift_invitations.projet_id)  LEFT OUTER JOIN agents ift_agent ON ( (projets.statut >= 5 AND projets.agent_instructeur_id = ift_agent.id) OR (projets.statut >= 1 AND projets.statut < 5 AND projets.agent_operateur_id = ift_agent.id) )  LEFT OUTER JOIN intervenants ift_intervenant ON (ift_invitations.intervenant_id = ift_intervenant.id AND ( (projets.statut >= 5 AND 'instructeur' = ANY(ift_intervenant.roles)) OR (projets.statut >= 1 AND projets.statut < 5 AND projets.operateur_id is not null AND 'operateur' = ANY(ift_intervenant.roles)) OR ('pris' = ANY(ift_intervenant.roles) AND projets.statut <= 1 AND projets.operateur_id is null)))  LEFT OUTER JOIN avis_impositions ift_avis_impositions2 ON (projets.id = ift_avis_impositions2.projet_id and (ift_avis_impositions2.annee < #{anne_var} or (ift_avis_impositions2.annee = #{anne_var} and #{month_var} >= 9)))"
        to_join_with_messages_agent_projet = "INNER JOIN messages ift_messages ON (projets.id = ift_messages.projet_id) INNER JOIN agents_projets ift_agents_projets ON (projets.id = ift_agents_projets.projet_id) INNER JOIN avis_impositions ift_avis_impositions ON (projets.id = ift_avis_impositions.projet_id) INNER JOIN occupants demandeur ON (ift_avis_impositions.id = demandeur.avis_imposition_id AND demandeur.demandeur = true) INNER JOIN adresses ift_adresse ON (projets.adresse_a_renover_id = ift_adresse.id) OR (projets.adresse_postale_id = ift_adresse.id AND projets.adresse_a_renover_id is NULL)  LEFT OUTER JOIN invitations on projets.id = invitations.projet_id  LEFT OUTER JOIN intervenants ON  invitations.intervenant_id = intervenants.id  LEFT OUTER JOIN projets_themes ift_ptheme ON (projets.id = ift_ptheme.projet_id)  LEFT OUTER JOIN themes ift_themes ON (ift_ptheme.theme_id = ift_themes.id)  LEFT OUTER JOIN invitations ift_invitations ON (projets.id = ift_invitations.projet_id)  LEFT OUTER JOIN agents ift_agent ON ( (projets.statut >= 5 AND projets.agent_instructeur_id = ift_agent.id) OR (projets.statut >= 1 AND projets.statut < 5 AND projets.agent_operateur_id = ift_agent.id) )  LEFT OUTER JOIN intervenants ift_intervenant ON (ift_invitations.intervenant_id = ift_intervenant.id AND ( (projets.statut >= 5 AND 'instructeur' = ANY(ift_intervenant.roles)) OR (projets.statut >= 1 AND projets.statut < 5 AND projets.operateur_id is not null AND 'operateur' = ANY(ift_intervenant.roles)) OR ('pris' = ANY(ift_intervenant.roles) AND projets.statut <= 1 AND projets.operateur_id is null)))  LEFT OUTER JOIN avis_impositions ift_avis_impositions2 ON (projets.id = ift_avis_impositions2.projet_id and (ift_avis_impositions2.annee < #{anne_var} or (ift_avis_impositions2.annee = #{anne_var} and #{month_var} >= 9)))"
        if current_agent.admin?
          if is_there_search?(search)
            @dossiers, @inactifs, @non_eligible, @non_eligible_a_reeval, @non_eligible_confirm = Projet.all.search_dossier(search, to_select, to_join)
          end
        elsif current_agent.dreal?
          if is_there_search?(search)
            @dossiers, @inactifs, @non_eligible, @non_eligible_a_reeval, @non_eligible_confirm = current_agent.intervenant.projets.search_dossier(search, to_select, to_join)
          end
        elsif current_agent.siege?
          if is_there_search?(search)
            @dossiers, @inactifs, @non_eligible, @non_eligible_a_reeval, @non_eligible_confirm =  Projet.with_demandeur.search_dossier(search, to_select, to_join)
          end
        else
          intervenant_id = current_agent.intervenant.id
          if current_agent.operateur?
            @dossiers = Projet.select(to_select).joins(to_join_with_messages_agent_projet).where(["invitations.intervenant_id = ?", intervenant_id]).where(["projets.operateur_id is NULL or projets.operateur_id = ?", intervenant_id]).group("projets.id")
          else
            @dossiers = Projet.select(to_select).joins(to_join_with_messages_agent_projet).where(["invitations.intervenant_id = ?", intervenant_id]).group("projets.id")
          end
          @dossiers, @inactifs, @non_eligible, @non_eligible_a_reeval, @non_eligible_confirm = @dossiers.search_dossier(search, to_select, to_join_with_messages_agent_projet)
          fill_tab_intervenant(@dossiers)
        end

        @traited = @traited.paginate(page: page_traited, per_page: per_page)
        @action = @action.paginate(page: page_action, per_page: per_page)
        @verif = @verif.paginate(page: page_verif, per_page: per_page)
        @new_msg = @new_msg.paginate(page: page_new_msg, per_page: per_page)
        @others = @others.paginate(page: page_others, per_page: per_page)
        @inactifs = @inactifs.paginate(page: page_inactifs, per_page: per_page)
        @rfrn2 = @rfrn2.paginate(page: page_rfrn2, per_page: per_page)
        @dossiers = @dossiers.paginate(page: page, per_page: per_page)
        @non_eligible = @non_eligible.paginate(page: page_noel, per_page: per_page)
        @non_eligible_a_reeval = @non_eligible_a_reeval.paginate(page: page_noelre, per_page: per_page)
        @non_eligible_confirm = @non_eligible_confirm.paginate(page: page_noelco, per_page: per_page)

        @statuses = Projet::INTERVENANT_STATUSES.inject([["", ""]]) { |acc, x| acc << [I18n.t("projets.statut.#{x}"), x] }
        @sort_by_options = Projet::SORT_BY_OPTIONS.map { |x| [I18n.t("projets.sort_by_options.#{x}"), x] }
      }
      format.csv {
        return render_csv(search)
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
