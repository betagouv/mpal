class TransmissionController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  before_action :init_view

  def new
    render :new
  end

  def create
    instructeur = fetch_instructeur
    if @projet_courant.transmettre!(instructeur)
      infos = [instructeur.raison_sociale, instructeur.adresse_postale, instructeur.phone].reject(&:blank?)
      redirect_to projet_path(@projet_courant), notice: t('projets.transmission.messages.success', instructeur: infos.join(", "))
    else
      redirect_to projet_transmission_path(@projet_courant), alert: t('projets.transmission.messages.error')
    end
  end

private
  def fetch_instructeur
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      rod_response.instructeur
    else
      @projet_courant.intervenants_disponibles(role: :instructeur).first
    end
  end

  def init_view
    @page_heading = 'Accepter la proposition'
  end
end

