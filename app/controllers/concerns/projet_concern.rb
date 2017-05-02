module ProjetConcern
  extend ActiveSupport::Concern

  included do
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
      #TODO prestations = Prestation.active | @projet_courant.prestations
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

    def show
      render_show
    end

private

    def render_show
      gon.push({
        latitude:  @projet_courant.adresse.try(:latitude),
        longitude: @projet_courant.adresse.try(:longitude)
      })
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
      @commentaire = Commentaire.new(projet: @projet_courant)
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/show"
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
              :prestation_choices_attributes => [:id, :prestation_id, :desired, :recommended, :selected],
              :projet_aides_attributes => [:id, :aide_id, :localized_amount],
              :demande => [:annee_construction],
      )
      if attributs[:projet_aides_attributes].present?
        attributs[:projet_aides_attributes].values.each do |projet_aide|
          projet_aide[:_destroy] = true if projet_aide[:localized_amount].blank?
        end
      end
      if attributs[:prestation_choices_attributes].present?
        attributs[:prestation_choices_attributes].values.each do |prestation_choice|
          prestation_choice[:_destroy] = true if prestation_choice[:desired].blank? && prestation_choice[:recommended].blank? && prestation_choice[:selected].blank?
        end
      end
      attributs
    end

    def assign_projet_if_needed
      if !@projet_courant.agent_operateur && current_agent
        if @projet_courant.update_attribute(:agent_operateur, current_agent)
          flash.now[:notice] = t('projets.visualisation.projet_affecte')
        end
      end
    end

    def prestations_with_choices
      Prestation.joins("LEFT OUTER JOIN prestation_choices ON prestation_choices.prestation_id = prestations.id AND prestation_choices.projet_id = #{ActiveRecord::Base.sanitize(@projet_courant.id)}").distinct.select('prestations.*, prestation_choices.desired AS desired, prestation_choices.recommended AS recommended, prestation_choices.selected AS selected, prestation_choices.id AS prestation_choice_id')
    end
  end
end
