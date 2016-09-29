class TransmissionsController < ApplicationController
  def create
    instructeur = Intervenant.instructeur_pour(@projet_courant)
    if @projet_courant.transmettre!(instructeur)
      redirect_to projet_demande_path(@projet_courant), notice: t('transmission.messages.succes')
    else
      redirect_to root_path
    end
  end
end
