module API
  class ProjetsController < ApplicationController
    def show
      projet = Projet.find(params[:id])
      render json: projet.as_json(only: [:usager, :adresse])
    end
  end
end
