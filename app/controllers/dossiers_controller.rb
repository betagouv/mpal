class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties

  before_action :authenticate_agent!
  before_action :assert_projet_courant, except: [:index, :indicateurs]
  load_and_authorize_resource class: "Projet"
  skip_load_and_authorize_resource only: [:index, :indicateurs]

  def index
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
        @page_heading = I18n.t('tableau_de_bord.titre_section')
      }
      format.csv {
        response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
        response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
        return render text: Projet.to_csv(current_agent)
      }
    end

    return render "dossiers/dashboard_siege"       if current_agent.siege?
    return render "dossiers/dashboard_operateur"   if current_agent.operateur?
    return render "dossiers/dashboard_instructeur" if current_agent.instructeur?
    render "dossiers/dashboard_pris"
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
      if @projet_courant.save_proposition!(projet_params) && @projet_courant.demande.update(annee_construction: demande_params[:annee_construction])
        return redirect_to projet_or_dossier_path(@projet_courant), notice: t('projets.edition_projet.messages.succes')
      else
        flash.now[:alert] = t('projets.edition_projet.messages.erreur')
      end
    end

    assign_projet_if_needed
    @themes = Theme.ordered.all
    @prestations_with_choices = prestations_with_choices
    define_helps
    render "projets/proposition"
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
      render_show
    end
  end

  def recommander_operateurs
    if request.post?
      begin
        if @projet_courant.suggest_operateurs!(suggested_operateurs_params[:suggested_operateur_ids])
          message = I18n.t('recommander_operateurs.succes',
                           count:     @projet_courant.pris_suggested_operateurs.count,
                           demandeur: @projet_courant.demandeur.fullname)
          redirect_to(dossier_path(@projet_courant), notice: message)
        end
      rescue => e
        logger.error e.message
        redirect_to dossier_path(@projet_courant), alert: "Une erreur s’est produite lors de la recommendation : le demandeur s'est engagé avec un opérateur"
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

    if current_agent.instructeur? || current_agent.dreal?
      departements = current_agent.intervenant.departements
      projets = departements.map { |d| Projet.all.select { |p| p.adresse.try(:departement) == d } }.flatten

      all_projets_status = projets.map(&:status_for_intervenant)
      @projets_count = projets.count
      status_count = Projet::INTERVENANT_STATUSES.map { |s| all_projets_status.count(s) }
      @projets = Projet::INTERVENANT_STATUSES.zip(status_count).to_h
    elsif current_agent.siege?
      all_projets_status = Projet.all.map(&:status_for_intervenant)
      @projets_count = all_projets_status.count
      status_count = Projet::INTERVENANT_STATUSES.map { |s| all_projets_status.count(s) }
      @projets = Projet::INTERVENANT_STATUSES.zip(status_count).to_h
    else
      redirect_to dossiers_path, alert: t('sessions.access_forbidden')
    end
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
    attributs = params.require(:projet)
                .permit(:disponibilite, :description, :email, :tel, :date_de_visite,
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
                        :theme_ids => [],
                        :suggested_operateur_ids => [],
                        :prestation_choices_attributes => [:prestation_id, :desired, :recommended, :selected],
                        :projet_aides_attributes => [:aide_id, :localized_amount],
                )
    clean_projet_aides(attributs)
    clean_prestation_choices(attributs)
    attributs
  end

  def demande_params
    attributs = params.require(:projet).permit(:demande_attributes => [:annee_construction])[:demande_attributes]
    attributs ? attributs : {}
  end

  def clean_projet_aides(attributs)
    if attributs[:projet_aides_attributes].present?
      attributs[:projet_aides_attributes].values.each do |projet_aide|
        projet_aide_to_modify = ProjetAide.where(aide_id: projet_aide[:aide_id], projet_id: @projet_courant.id).first
        projet_aide[:id] = projet_aide_to_modify.try(:id)

        amount = projet_aide[:localized_amount]
        projet_aide[:_destroy] = true if amount.blank? || BigDecimal(amount) == 0
      end
    end
  end

  def clean_prestation_choices(attributs)
    if attributs[:prestation_choices_attributes].present?
      attributs[:prestation_choices_attributes].values.each do |prestation_choice|
        prestation_choice_to_modify = PrestationChoice.where(prestation_id: prestation_choice[:prestation_id], projet_id: @projet_courant.id).first
        prestation_choice[:id] = prestation_choice_to_modify.try(:id)

        if [:desired, :recommended, :selected].any? { |key| prestation_choice.key? key }
          fill_blank_values_with_false(prestation_choice)
        else
          prestation_choice[:_destroy] = true
        end
      end
    end
    attributs
  end

  def fill_blank_values_with_false(prestation_choice)
    prestation_choice[:desired]     = prestation_choice[:desired].present?
    prestation_choice[:recommended] = prestation_choice[:recommended].present?
    prestation_choice[:selected]    = prestation_choice[:selected].present?
    prestation_choice
  end

  def suggested_operateurs_params
    attributes = params
      .fetch(:projet, {})
      .permit(:suggested_operateur_ids => [])
    attributes[:suggested_operateur_ids] ||= []
    attributes
  end
end
