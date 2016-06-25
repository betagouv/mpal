class ProjetsController < ApplicationController

  def edit

  end

  def update
    projet.assign_attributes(projet_params)
    if projet.save
      redirect_to projet
    else
      render :edit
    end
  end

  def show
    gon.push({
      latitude: projet.latitude,
      longitude: projet.longitude
    })
    @profil = projet.usager
    @intervenants_disponibles = projet.intervenants_disponibles(role: :pris)
  end

  private
  def projet_params
    service_adresse = ApiBan.new
    adresse = service_adresse.precise(params[:projet][:adresse])
    attributs = params.require(:projet).permit(:description, :email, :tel)
    attributs = attributs.merge(adresse) if adresse
    attributs
  end

  def projet
    @projet ||= Projet.find(params[:id])
  end
end
