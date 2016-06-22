class OccupantsController < ApplicationController
  def new
    @projet = Projet.find(params[:projet_id])
    @occupant = @projet.occupants.build
  end

  def create
    redirect_to root_path
  end
end

