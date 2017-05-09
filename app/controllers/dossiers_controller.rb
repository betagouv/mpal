class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties

  before_action :authenticate_agent!
  before_action :projet_or_dossier
  before_action :assert_projet_courant, except: [:index]

  def index
    @dossiers = Projet.for_agent(current_agent)
    respond_to do |format|
      format.html {
        @page_heading = I18n.t('tableau_de_bord.titre_section')
      }
      format.csv {
        response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
        response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
        render text: Projet.to_csv(current_agent)
      }
    end
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
      if @projet_courant.save_proposition!(projet_params)
        return redirect_to projet_or_dossier_path(@projet_courant), notice: t('projets.edition_projet.messages.succes')
      else
        flash.now[:alert] = t('projets.edition_projet.messages.erreur')
      end
    end

    assign_projet_if_needed
    @themes = Theme.ordered.all
    @prestations_with_choices = prestations_with_choices
    @aides_publiques = Aide.public_assistance.active     | @projet_courant.aides.public_assistance
    @aides_privees   = Aide.not_public_assistance.active | @projet_courant.aides.not_public_assistance
    render "projets/proposition"
  end

  def proposer
    @projet_courant.statut = :proposition_proposee
    if @projet_courant.save(context: :proposition)
      return redirect_to projet_or_dossier_path(@projet_courant)
    else
      @projet_courant.restore_statut!
      render_show
    end
  end

  def recommander_operateurs
    if request.post?
      if @projet_courant.suggest_operateurs!(suggested_operateurs_params[:suggested_operateur_ids])
        message = I18n.t('recommander_operateurs.succes',
                          count:     @projet_courant.suggested_operateurs.count,
                          demandeur: @projet_courant.demandeur.fullname)
        redirect_to(dossier_path(@projet_courant), notice: message)
      end
    end

    @available_operateurs = @projet_courant.intervenants_disponibles(role: :operateur).to_a
    if @projet_courant.suggested_operateurs.blank? && !request.post?
      @available_operateurs.shuffle!
    end
  end

private

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

  def prestations_with_choices
    # This query be simplified by using `left_joins` once we'll be running on Rails 5
    Prestation
      .active_for_projet(@projet_courant)
      .joins("LEFT OUTER JOIN prestation_choices ON prestation_choices.prestation_id = prestations.id AND prestation_choices.projet_id = #{ActiveRecord::Base.sanitize(@projet_courant.id)}")
      .distinct
      .select('prestations.*, prestation_choices.desired AS desired, prestation_choices.recommended AS recommended, prestation_choices.selected AS selected, prestation_choices.id AS prestation_choice_id')
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
                        :demande => [:annee_construction],
                )
    clean_projet_aides(attributs)
    clean_prestation_choices(attributs)
    attributs
  end

  def clean_projet_aides(attributs)
    if attributs[:projet_aides_attributes].present?
      attributs[:projet_aides_attributes].values.each do |projet_aide|
        projet_aide_to_modifiy = ProjetAide.where(aide_id: projet_aide[:aide_id], projet_id: @projet_courant.id).first
        projet_aide[:id] = projet_aide_to_modifiy.try(:id)

        projet_aide[:_destroy] = true if projet_aide[:localized_amount].blank?
      end
    end
  end

  def clean_prestation_choices(attributs)
    if attributs[:prestation_choices_attributes].present?
      attributs[:prestation_choices_attributes].values.each do |prestation_choice|
        prestation_choice_to_modifiy = PrestationChoice.where(prestation_id: prestation_choice[:prestation_id], projet_id: @projet_courant.id).first
        prestation_choice[:id] = prestation_choice_to_modifiy.try(:id)

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
