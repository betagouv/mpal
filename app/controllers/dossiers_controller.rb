class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties

  before_action :authenticate_agent!
  before_action :assert_projet_courant, except: [:index, :indicateurs]
  load_and_authorize_resource class: "Projet"
  skip_load_and_authorize_resource only: [:index, :home, :indicateurs]

  def index
    if render_index
      @page_heading = I18n.t('tableau_de_bord.titre_section')
      return render "dossiers/dashboard_siege"       if current_agent.siege?
      return render "dossiers/dashboard_operateur"   if current_agent.operateur?
      return render "dossiers/dashboard_instructeur" if current_agent.instructeur?
      render "dossiers/dashboard_pris"
    end
  end

  def home
    @page_heading = "Accueil"
    render_index
  end

  def affecter_agent
    if @projet_courant.update_attribute(:agent, current_agent)
      flash[:notice] = t('projets.visualisation.projet_affecte')
    else
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to dossier_path(@projet_courant)
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
    render_show
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

private
  def fetch_operateurs
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      rod_response.operateurs
    else
      @projet_courant.intervenants_disponibles(role: :operateur)
    end
  end

  def assign_projet_if_needed
    if !@projet_courant.agent_operateur && current_agent
      if @projet_courant.update_attribute(:agent_operateur, current_agent)
        flash.now[:notice] = t('projets.visualisation.projet_affecte')
      end
    end
  end

  def export_filename
    "dossiers_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.csv"
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
        :demande_attributes => [:annee_construction],
        :theme_ids => [],
        :suggested_operateur_ids => [],
        :prestation_choices_attributes => [:prestation_id, :desired, :recommended, :selected],
        :projet_aides_attributes => [:aide_id, :localized_amount]
    )
    clean_projet_aides(attributes)
    clean_prestation_choices(attributes)
    attributes
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

  def fill_blank_values_with_false(prestation_choice)
    prestation_choice[:desired]     = prestation_choice[:desired].present?
    prestation_choice[:recommended] = prestation_choice[:recommended].present?
    prestation_choice[:selected]    = prestation_choice[:selected].present?
    prestation_choice
  end

  def render_index
    if current_agent.dreal?
      return redirect_to indicateurs_dossiers_path
    end
    if current_agent.siege?
      @dossiers = Projet.all.with_demandeur
    elsif current_agent.operateur?
      @invitations = Invitation.visible_for_operateur(current_agent.intervenant)
    else
      @invitations = Invitation.where(intervenant_id: current_agent.intervenant_id).includes(:projet)
    end
    respond_to do |format|
      format.html {
      }
      format.csv {
        response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
        response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
        render plain: Projet.to_csv(current_agent)
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
end
