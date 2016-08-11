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
    @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
    @commentaire = Commentaire.new(projet: @projet_courant)
    @revenu_total_boo = @projet_courant.calcul_revenu_fiscal_reference_total(:annee)
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
