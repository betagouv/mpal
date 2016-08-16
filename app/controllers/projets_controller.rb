class ProjetsController < ApplicationController

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
  end

  def demande
    @instructeur = Intervenant.pour_departement(@projet_courant.departement, role: 'instructeur').first
  end

  private

  def projet_params
    service_adresse = ApiBan.new
    adresse = service_adresse.precise(params[:projet][:adresse])
    attributs = params.require(:projet).permit(:description, :email, :tel, :adresse)
    attributs = attributs.merge(adresse) if adresse
    attributs
  end

  def valid?
    @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
    @projet_courant.adresse.present?
  end

end
