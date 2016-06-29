class ProjetsController < ApplicationController

  def edit
    @projet = @projet_courant
  end

  def update
    @projet = @projet_courant
    @projet.assign_attributes(projet_params)
    if @projet.save
      redirect_to @projet
    else
      render :edit
    end
  end

  def show
    @projet = @projet_courant
    gon.push({
      latitude: @projet.latitude,
      longitude: @projet.longitude
    })
    @profil = @projet.usager
    case @role_utilisateur 
      when :demandeur; @intervenants_disponibles = @projet.intervenants_disponibles(role: :pris)
      when :intervenant; @intervenants_disponibles = @projet.intervenants_disponibles(role: :operateur)
    end
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
