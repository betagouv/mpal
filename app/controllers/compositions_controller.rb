class CompositionsController < ApplicationController

  def edit
    @nb_total_occupants = @projet_courant.nb_total_occupants
  end

  def update
    @projet_courant.nb_occupants_a_charge = params[:projet][:nb_occupants_a_charge]
    if @projet_courant.save
      redirect_to projet_path(@projet_courant), notice: t('projets.composition_logement.messages.succes')
    else
      render :edit, notice: @projet_courant.errors
    end
  end

end
