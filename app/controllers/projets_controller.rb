class ProjetsController < ApplicationController
  def new
    @projet = Projet.new
  end

  def create
    facade = ProjetFacade.new(ApiParticulier.new)
    projet_params = params[:projet]
    @projet = facade.initialise_projet(projet_params[:numero_fiscal], projet_params[:reference_avis], projet_params[:description])
    if @projet.save
      redirect_to projet_path(@projet)
    else 
      render :new
    end
  end

  def show
    @projet = Projet.find(params[:id])
    @contact = @projet.contacts.build
    @contact.role = 'syndic'
  end
end
