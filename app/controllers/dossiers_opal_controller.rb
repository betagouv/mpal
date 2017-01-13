class DossiersOpalController < ApplicationController
  def create
    unless (@role_utilisateur == :intervenant) && (@utilisateur_courant.instructeur?)
      return redirect_to(projet_path(@projet_courant), alert: t('sessions.access_forbidden'))
    end
    unless Opal.new(OpalClient).creer_dossier(@projet_courant)
      return redirect_to(projet_path(@projet_courant), alert: t('projets.creation_opal.messages.erreur'))
    end
    redirect_to(projet_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_numero))
  end
end
