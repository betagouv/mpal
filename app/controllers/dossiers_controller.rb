class DossiersController < ApplicationController
  def create
    if (@role_utilisateur == :intervenant) && (@utilisateur_courant.instructeur?)
      if Opal.new(OpalClient).creer_dossier(@projet_courant)
        redirect_to(projet_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_id))
      else
        redirect_to(projet_path(@projet_courant), alert: t('projets.creation_opal.messages.erreur'))
      end
    else
      redirect_to(projet_path(@projet_courant), alert: t('sessions.access_forbidden'))
    end
  end
end
