class OccupantsController < ApplicationController

  def new
    @occupant = projet.occupants.build
  end

  def edit
    @occupant = projet.occupants.where(id: params[:id]).first
    render :edit
  end

  def create
    @occupant = projet.occupants.build(occupant_params)
    if @occupant.save
      redirect_to projet
    else
      render :new
    end
  end

  def update
    @occupant = projet.occupants.where(id: params[:id]).first
    if @occupant.update_attributes(occupant_params)
      redirect_to projet_path(projet), notice: "L'occupant #{@occupant} a bien été modifié"
    else
      render :edit
    end
  end

  def composition
  end

  private

  def occupant_params
    params.require(:occupant).permit(:civilite, :prenom, :nom, :date_de_naissance, :lien_demandeur, :demandeur)
  end

  def projet
    @projet ||= @projet_courant
  end
end
