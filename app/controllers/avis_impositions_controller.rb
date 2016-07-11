class AvisImpositionsController < ApplicationController
  before_action :get_avis_imposition, only: [:create, :destroy]

  def new
    @avis_imposition = AvisImposition.new
  end

  def create
    @avis_imposition.create(avis_imposition_params)
  end

  def destroy
    @avis_imposition.destroy
  end

  private

  def get_avis_imposition
    @avis_imposition = AvisImposition.find_by(id: params[:id])
  end

  def avis_imposition_params
    params.require(:avis_imposition).permit(:numero_fiscal, :reference_avis)
  end
end
