class ProjetsController < ApplicationController
  def new
    @projet = Projet.new
  end

  def create
    facade = ProjetFacade.new(params.require(:projet).permit(:numero_fiscal, :reference_avis, :description))
    @projet = facade.projet
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
