module ProjetConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_heading

    def accepter
      @projet_courant.statut = :proposition_acceptee
      if @projet_courant.save
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant)
      end
      render "projets/edit"
    end

    # ATTENTION à la confusion avec la table demandes qui correspond au projet envisagé
    # par le demandeur lors des premières étapes voir demarrage_projet
    def demande
      if @projet_courant.prospect?
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant), alert: t('sessions.access_forbidden')
      end
      if !@projet_courant.agent && current_agent
        if @projet_courant.update_attribute(:agent, current_agent)
          flash[:notice] = t('projets.visualisation.projet_affecte')
        end
      end
      @projet_courant.documents.build(label: "Evaluation énergétique")
      @projet_courant.documents.build(label: "Decision CDAPH ou GIR")
      @projet_courant.documents.build(label: "Rapport d'ergotherpeute ou diagnostic autonomie")
      @projet_courant.documents.build(label: "Grille de degradation ou arrêté")
      @projet_courant.documents.build(label: "Grille d'insalubrité ou arrêté")
      @projet_courant.documents.build(label: "Devis ou estimation de travaux")
      @projet_courant.documents.build(label: "Justificatif MDPH")
      @projet_courant.documents.build(label: "Justificatif CDAPH")
      render "projets/demande"
    end

    def proposer
      @projet_courant.statut = :proposition_proposee
      if @projet_courant.save
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant)
      end
      render "projets/edit"
    end

    def show
      gon.push({
        latitude: @projet_courant.latitude,
        longitude: @projet_courant.longitude
      })
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
      @commentaire = Commentaire.new(projet: @projet_courant)
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/show"
    end

    def suivi
      @commentaire = Commentaire.new(projet: @projet_courant)
      @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
      render "projets/suivi"
    end

    def update
      @projet_courant.statut = :proposition_enregistree
      @projet_courant.assign_attributes(projet_params)
      if projet_valide? && @projet_courant.save
        return redirect_to send("#{@dossier_ou_projet}_path", @projet_courant), notice: t('projets.edition_projet.messages.succes')
      end
      render "projets/edit", alert: t('projets.edition_projet.messages.erreur')
    end

    private
    def email_valide?(email)
      email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i) || email.empty?
    end

    def projet_params
      adresse = params[:projet][:adresse]
      if adresse
        service_adresse = ApiBan.new
        adresse_complete = service_adresse.precise(adresse)
      end
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
              :prestation_ids => [])
      attributs[:prestation_ids] = [] if attributs[:prestation_ids].blank?
      attributs = attributs.merge(adresse_complete) if adresse_complete
      attributs
    end

    def projet_valide?
      @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
      @projet_courant.errors[:email] = t('projets.edition_projet.messages.erreur_email_invalide') unless email_valide?(@projet_courant.email)
      @projet_courant.adresse.present? && email_valide?(@projet_courant.email)
    end

    def set_heading
      @page_heading = "Dossier : #{I18n.t(@projet_courant.statut, scope: "projets.statut").downcase}" if @projet_courant
    end
  end
end
