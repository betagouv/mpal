class ProjetsController < ApplicationController
  def edit
    @projet = Projet.find(params[:id])
  end

  def update
    @projet = Projet.find(params[:id])
    @projet.adresse = params[:projet][:adresse]
    if @projet.save
      redirect_to @projet
    else
      render :edit
    end
  end

  def show
    @projet = Projet.find(params[:id])
    if session[:numero_fiscal] != @projet.numero_fiscal
      redirect_to new_session_path, alert: t('sessions.access_forbidden')
    else
      gon.push({
        latitude: @projet.latitude,
        longitude: @projet.longitude
      })
      @operateurs_departement = Operateur.pour_departement(@projet.departement) - @projet.operateurs
    end
  end
end
