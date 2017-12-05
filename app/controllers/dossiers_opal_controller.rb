class DossiersOpalController < ApplicationController
  before_action :authenticate_agent!
  before_action :assert_projet_courant
  authorize_resource :class => false

  def create
    begin
      opal_api.create_dossier!(@projet_courant, current_agent)
      redirect_to(dossier_path(@projet_courant), notice: t('projets.creation_opal.messages.succes', id_opal: @projet_courant.opal_numero))
    rescue => e
      redirect_to(dossier_path(@projet_courant), alert: ("Une erreur est survenue lors de la creation du dossier dans Opal : " + e.message).force_encoding Encoding::UTF_8)
    end
  end

private
  def opal_api
    @opal_api ||= Opal.new(OpalClient)
  end

end
