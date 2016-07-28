class PrestationsController < ApplicationController
  def create
    prestation = @projet_courant.prestations.build(prestation_params)
    prestation.save
    redirect_to projet_demande_path(@projet_courant)
  end

  private
  def prestation_params
    params.require(:prestation).permit(:libelle, :scenario)
  end
end
