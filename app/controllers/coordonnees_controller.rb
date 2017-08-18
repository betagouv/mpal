class CoordonneesController < ApplicationController

  before_action :assert_projet_courant
  authorize_resource :class => false

  def show
    @pris = @projet_courant.invited_pris
    @operateur = @projet_courant.operateur
    @instructeur = @projet_courant.invited_instructeur
    @demandeur = @projet_courant.demandeur
  end
end
