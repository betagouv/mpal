module API
  class ProjetsController < ApplicationController
    def show
      projet = Projet.find(params[:id])
      render json: projet
    end
  end
end
