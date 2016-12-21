class ProjetsController < ApplicationController
  def index
    if @role_utilisateur == :intervenant
      @invitations = @utilisateur_courant.invitations
    else
      redirect_to projet_path(@projet_courant)
    end
  end

  def edit
  end

  def update
    @projet_courant.statut = :proposition_enregistree
    @projet_courant.assign_attributes(projet_params)
    if projet_valide? && @projet_courant.save
      redirect_to @projet_courant, notice: t('projets.edition_projet.messages.succes')
    else
      render :edit, alert: t('projets.edition_projet.messages.erreur')
    end
  end

  def proposer
    @projet_courant.statut = :proposition_proposee
    if @projet_courant.save
      redirect_to @projet_courant
    else
      render :edit
    end
  end

  def accepter
    @projet_courant.statut = :proposition_acceptee
    if @projet_courant.save
      redirect_to @projet_courant
    else
      render :edit
    end
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
  end

  def demande
    # attention à la confusion avec la table demandes qui correspond au projet envisagé par le demandeur lors des premières étapes voir demarrage_projet
    if @projet_courant.prospect?
      redirect_to projet_path(@projet_courant), alert: t('sessions.access_forbidden')
    else
      @projet_courant.documents.build(label: "Evaluation énergétique")
      @projet_courant.documents.build(label: "Decision CDAPH ou GIR")
      @projet_courant.documents.build(label: "Rapport d'ergotherpeute ou diagnostic autonomie")
      @projet_courant.documents.build(label: "Grille de degradation ou arrêté")
      @projet_courant.documents.build(label: "Grille d'insalubrité ou arrêté")
      @projet_courant.documents.build(label: "Devis ou estimation de travaux")
      @projet_courant.documents.build(label: "Justificatif MDPH")
      @projet_courant.documents.build(label: "Justificatif CDAPH")

    end
  end

  def suivi
    @commentaire = Commentaire.new(projet: @projet_courant)
    @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
  end

  private

  def projet_params
    if params[:projet][:adresse]
      service_adresse = ApiBan.new
      adresse_complete = service_adresse.precise(params[:projet][:adresse])
    end
    attributs = params.require(:projet)
      .permit(:disponibilite, :description, :email, :tel, :annee_construction, :nb_occupants_a_charge,
              :type_logement, :etage, :nb_pieces, :surface_habitable, :etiquette_avant_travaux,
              :niveau_gir, :handicap, :demandeur_salarie, :entreprise_plus_10_personnes,
              :note_degradation, :note_insalubrite, :ventilation_adaptee, :presence_humidite, :auto_rehabilitation,
              :remarques_diagnostic,
              :gain_energetique, :etiquette_apres_travaux,
              :precisions_travaux, :precisions_financement,
              :montant_travaux_ht, :montant_travaux_ttc, :pret_bancaire, :reste_a_charge,
              :documents_attributes)
    attributs = attributs.merge(adresse_complete) if adresse_complete
    attributs
  end

end
