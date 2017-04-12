class DossiersOpalController < ApplicationController
  before_action :authenticate_agent!
  before_action :check_agent_instructeur
  before_action :assert_projet_courant

  def create
    begin
      opal_api.create_dossier!(@projet_courant, current_agent)
      redirect_to(dossier_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_numero))
    rescue => e
      redirect_to(dossier_path(@projet_courant), alert: t('projets.creation_opal.messages.erreur', message: e.message))
    end
  end

private
  def opal_api
    @opal_api ||= Opal.new(OpalClient)
  end

  def check_agent_instructeur
    unless current_agent.instructeur?
      return redirect_to(dossier_path(@projet_courant), alert: t('sessions.access_forbidden'))
    end
    true
  end
end
