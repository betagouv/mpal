class ProjetsController < ApplicationController
  def new
    @projet = Projet.new
  end

  def create
    facade = ProjetFacade.new(ApiParticulier.new)
    projet_params = params[:projet]
    @projet = facade.initialise_projet(projet_params[:numero_fiscal], projet_params[:reference_avis], projet_params[:description])
    if @projet.save
      session[:numero_fiscal] = projet_params[:numero_fiscal]
      redirect_to projet_path(@projet)
    else 
      render :new
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
      @contact = @projet.contacts.build
      @contact.role = 'syndic'
    end
  end
end
