class DossiersOpalController < ApplicationController
  before_action :authenticate_agent!
  before_action :check_agent_instructeur

  def create
    unless Opal.new(OpalClient).creer_dossier(@projet_courant)
      return redirect_to(dossier_path(@projet_courant), alert: t('projets.creation_opal.messages.erreur'))
    end
    redirect_to(dossier_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_numero))
  end

private
  def check_agent_instructeur
    unless current_agent.instructeur?
      return redirect_to(dossier_path(@projet_courant), alert: t('sessions.access_forbidden'))
    end
    true
  end
end
