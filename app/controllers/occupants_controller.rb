class OccupantsController < ApplicationController

  def new
    @occupant = @projet_courant.occupants.build
  end

  def edit
    @occupant = @projet_courant.occupants.where(id: params[:id]).first
    render :edit
  end

  def create
    @occupant = @projet_courant.occupants.build(occupant_params)
    if @occupant.save
      redirect_to @projet_courant
    else
      render :new
    end
  end

  def update
    @occupant = @projet_courant.occupants.where(id: params[:id]).first
    if @occupant.update_attributes(occupant_params)
      redirect_to projet_path(@projet_courant), notice: "L'occupant #{@occupant} a bien été modifié"
    else
      render :edit
    end
  end

  private

  def occupant_params
    params.require(:occupant).permit(
      :civilite,
      :prenom, :nom,
      :date_de_naissance,
      :lien_demandeur, :demandeur,
      :revenus
    )
  end

end
