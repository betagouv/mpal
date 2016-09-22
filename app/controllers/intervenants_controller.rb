class IntervenantsController < ApplicationController
  def index
    if @projet_courant.prospect?
      @pris_disponibles = @projet_courant.intervenants_disponibles(role: :pris)
      @operateurs_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle

      render "index_#{@projet_courant.statut}_#{@role_utilisateur}"
    else
      render "index"
    end
  end
end
