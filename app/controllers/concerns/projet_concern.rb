module ProjetConcern
  extend ActiveSupport::Concern

  included do
    def accepter
      @projet_courant.statut = :proposition_acceptee
      if @projet_courant.save
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant)
      end
      render "projets/show"
    end

    def proposition
      if @projet_courant.prospect?
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant), alert: t('sessions.access_forbidden')
      end

      if request.put?
        if @projet_courant.save_proposition!(projet_params)
          return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant), notice: t('projets.edition_projet.messages.succes')
        else
          flash[:alert] = t('projets.edition_projet.messages.erreur')
        end
      end

      assign_projet_if_needed
      @projet_courant.documents.build(label: "Evaluation énergétique")
      @projet_courant.documents.build(label: "Decision CDAPH ou GIR")
      @projet_courant.documents.build(label: "Rapport d'ergotherpeute ou diagnostic autonomie")
      @projet_courant.documents.build(label: "Grille de degradation ou arrêté")
      @projet_courant.documents.build(label: "Grille d'insalubrité ou arrêté")
      @projet_courant.documents.build(label: "Devis ou estimation de travaux")
      @projet_courant.documents.build(label: "Justificatif MDPH")
      @projet_courant.documents.build(label: "Justificatif CDAPH")
      render "projets/proposition"
    end

    def proposer
      @projet_courant.statut = :proposition_proposee
      if @projet_courant.save
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant)
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
      .permit(:disponibilite, :description, :email, :tel, :annee_construction, :nb_occupants_a_charge,
              :type_logement, :etage, :nb_pieces, :surface_habitable, :etiquette_avant_travaux,
              :niveau_gir, :autonomie, :handicap, :demandeur_salarie, :entreprise_plus_10_personnes,
              :note_degradation, :note_insalubrite, :ventilation_adaptee, :presence_humidite, :auto_rehabilitation,
              :remarques_diagnostic,
              :gain_energetique, :etiquette_apres_travaux,
              :precisions_travaux, :precisions_financement,
              :montant_travaux_ht, :montant_travaux_ttc, :pret_bancaire, :reste_a_charge,
              :documents_attributes,
              :prestation_ids => [],
              :suggested_operateur_ids => [],
              :projet_aides_attributes => [:id, :aide_id, :montant])
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
          flash[:notice] = t('projets.visualisation.projet_affecte')
        end
      end
    end
  end
end
