class CompositionsController < ApplicationController

  def edit
  end

  def update
    @projet_courant.nb_occupants_a_charge = params[:projet][:nb_occupants_a_charge]
    @projet_courant.save
    redirect_to edit_projet_composition_path(@projet_courant), notice: t('projets.composition_logement.messages.succes')
  end
end
