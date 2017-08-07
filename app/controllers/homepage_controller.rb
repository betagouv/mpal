class HomepageController < ApplicationController
  layout "creation_dossier"

  before_action :redirect_to_project_if_exists

  def index
    @homepage = true
    @page_heading = "Obtenez une aide financière pour améliorer votre logement"
  end
end

