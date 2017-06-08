class HomepageController < ApplicationController
  layout "creation_dossier"

  def index
    @page_heading = "Obtenez une aide financière pour améliorer votre logement"
  end
end

