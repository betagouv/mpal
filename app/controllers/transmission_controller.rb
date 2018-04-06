class TransmissionController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  before_action :init_view

  def new
    render :new
  end

  def create
    if @projet_courant.transmettre!(@projet_courant.invited_instructeur)
      instructeur = @projet_courant.invited_instructeur
      infos = [instructeur.raison_sociale, instructeur.adresse_postale, instructeur.phone].reject(&:blank?)
      redirect_to projet_path(@projet_courant), notice: t('projets.transmission.messages.success', instructeur: infos.join(", "))
    else
      redirect_to projet_transmission_path(@projet_courant), alert: t('projets.transmission.messages.error')
    end
  end

private
  def init_view
    @page_heading = 'Ma demande'
  end
end

