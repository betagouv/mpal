class IntervenantsController < ApplicationController
  def index
    @pris_disponibles = @projet_courant.intervenants_disponibles(role: :pris)
    @operateurs_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
  end
end
