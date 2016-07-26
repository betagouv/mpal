class ProjetsController < ApplicationController

  def edit
  end

  def update
    @projet_courant.assign_attributes(projet_params)
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
    if @utilisateur_courant.is_a? Intervenant
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur)
    else
      @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :pris)
    end
    @commentaire = Commentaire.new(projet: @projet_courant)
  end

  def calcul_revenu_fiscal_reference
    @calcul = @projet_courant.calcul_revenu_fiscal_reference(params[:annee])
    redirect_to edit_projet_composition_path(@projet_courant, calcul: @calcul)
  end

  def demande
    @instructeur = Intervenant.pour_departement(@projet_courant.departement, role: 'instructeur').first
  end

  private

  def projet_params
    service_adresse = ApiBan.new
    adresse = service_adresse.precise(params[:projet][:adresse])
    attributs = params.require(:projet).permit(:description, :email, :tel)
    attributs = attributs.merge(adresse) if adresse
    attributs
  end

end
