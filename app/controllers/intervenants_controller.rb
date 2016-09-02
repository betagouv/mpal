class IntervenantsController < ApplicationController
  def index
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
    @intervenants_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
  end
end
