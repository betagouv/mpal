class TransmissionsController < ApplicationController
  def create
    instructeur = Intervenant.instructeur_pour(@projet_courant)
    if @projet_courant.transmettre!(instructeur)
      redirect_to projet_path(@projet_courant), notice: t('projets.transmissions.messages.succes')
    else
      redirect_to projet_path(@projet_courant), notice: "Impossible de transmettre le dossier aux services instructeurs"
    end
  end
end
