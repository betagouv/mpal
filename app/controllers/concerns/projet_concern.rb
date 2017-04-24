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
      @prestations = Prestation.active | @projet_courant.prestations
      @aides_publiques = Aide.public_assistance.active     | @projet_courant.aides.public_assistance
      @aides_privees   = Aide.not_public_assistance.active | @projet_courant.aides.not_public_assistance
      render "projets/proposition"
    end

    def proposer
      @projet_courant.statut = :proposition_proposee
      if @projet_courant.save
        return redirect_to projet_or_dossier_path(@projet_courant)
      end
      render "projets/show"
    end

    def show
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

private

    def projet_params
      attributs = params.require(:projet)
      .permit(:disponibilite, :description, :email, :tel, :date_de_visite,
              :type_logement, :etage, :nb_pieces, :surface_habitable, :etiquette_avant_travaux,
              :niveau_gir, :autonomie, :handicap, :demandeur_salarie, :entreprise_plus_10_personnes,
              :note_degradation, :note_insalubrite, :ventilation_adaptee, :presence_humidite, :auto_rehabilitation,
              :remarques_diagnostic,
              :gain_energetique, :etiquette_apres_travaux,
              :precisions_travaux, :precisions_financement,
              :montant_travaux_ht, :assiette_subventionnable_amount, :amo_amount, :maitrise_oeuvre_amount, :montant_travaux_ttc,
              :pret_bancaire, :reste_a_charge,
              :documents_attributes,
              :prestation_ids => [],
              :theme_ids => [],
              :suggested_operateur_ids => [],
              :projet_aides_attributes => [:id, :aide_id, :localized_amount],
              :demande => [:annee_construction],
      )
      attributs[:prestation_ids] = [] if attributs[:prestation_ids].blank?
      if attributs[:projet_aides_attributes].present?
        attributs[:projet_aides_attributes].values.each do |projet_aide|
          projet_aide[:_destroy] = true if projet_aide[:montant].blank?
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
  end
end
