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
    @projet_courant.assign_attributes(projet_params)
    if valid? && @projet_courant.save
      redirect_to @projet_courant, notice: t('projets.edition_projet.messages.succes')
    else
      render :edit, alert: t('projets.edition_projet.messages.erreur')
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
  end

  def suivi
    @commentaire = Commentaire.new(projet: @projet_courant)
    @invitations_demandeur = Invitation.where(projet_id: @projet_courant.id)
  end


  private

  def projet_params
    service_adresse = ApiBan.new
    adresse_complete = service_adresse.precise(params[:projet][:adresse])
    attributs = params.require(:projet).permit(:description, :email, :tel, :annee_construction, :nb_occupants_a_charge)
    attributs = attributs.merge(adresse_complete) if adresse_complete
    attributs
  end

  def valid?
    @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
    @projet_courant.errors[:email] = t('projets.edition_projet.messages.erreur_email_invalide') unless email_valide?(@projet_courant.email)
    @projet_courant.adresse.present? && email_valide?(@projet_courant.email)
  end

end
