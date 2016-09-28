class TransmissionsController < ApplicationController
  def create
    if @projet_courant.transmettre_a_instructeur
      @projet_courant.save
      redirect_to projet_demande_path(@projet_courant), notice: t('transmission.messages.succes')
    else
      redirect_to root_path
    end
  end
end
