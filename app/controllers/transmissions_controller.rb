class TransmissionsController < ApplicationController
  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def create
    instructeur = Intervenant.instructeur_pour(@projet_courant)
    if @projet_courant.transmettre!(instructeur)
      redirect_to projet_path(@projet_courant), notice: t('projets.transmissions.messages.succes')
    else
      redirect_to projet_path(@projet_courant), notice: "Impossible de transmettre le dossier aux services instructeurs"
    end
  end
end
