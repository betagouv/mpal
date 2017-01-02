class DossiersController < ApplicationController
  skip_before_action :authentifie, only: [:show]

  def create
    if (@role_utilisateur == :intervenant) && (@utilisateur_courant.instructeur?)
      if Opal.new(OpalClient).creer_dossier(@projet_courant)
        redirect_to(projet_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_numero))
      else
        redirect_to(projet_path(@projet_courant), alert: t('projets.creation_opal.messages.erreur'))
      end
    else
      redirect_to(projet_path(@projet_courant), alert: t('sessions.access_forbidden'))
    end
  end

  def show
    numero_plateforme = params[:numero_plateforme]
    attributs = numero_plateforme.split('_')
    projet_id = attributs[0]
    plateforme_id = attributs[1]
    projet = Projet.where(id: projet_id, plateforme_id: plateforme_id).first
    if agent_signed_in?
      redirect_to projet_path(projet)
    else
      redirect_to new_agent_session_path(from: "opal", projet_id: projet.id)
    end
  end
end
