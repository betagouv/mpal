class MisesEnRelationController < ApplicationController
  layout 'inscription'

  before_action :projet_or_dossier
  before_action :assert_projet_courant
  before_action :authentifie

  def show
    @demande = @projet_courant.demande
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris).first
    if @pris_departement.blank?
      raise "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement}"
    end
    @page_heading = 'Inscription'
    @action_label = action_label
  end

  def update
    begin
      @projet_courant.update_attribute(:disponibilite, params[:projet][:disponibilite])
      intervenant = Intervenant.find_by_id(params[:intervenant])
      unless @projet_courant.intervenants.include? intervenant
        @projet_courant.invite_pris!(intervenant)
        flash[:notice_titre] = t('invitations.messages.succes_titre')
        flash[:notice] = t('invitations.messages.succes', intervenant: intervenant.raison_sociale)
      end
      redirect_to projet_path(@projet_courant)
    rescue => e
      logger.error e.message
      redirect_to projet_mise_en_relation_path(@projet_courant), alert: t('demarrage_projet.mise_en_relation.error')
    end
  end

private

  def action_label
    if needs_mise_en_relation?
      t('demarrage_projet.action')
    else
      t('projets.edition.action')
    end
  end

  def needs_mise_en_relation?
    @projet_courant.contacted_operateur.blank? && @projet_courant.invited_pris.blank?
  end
end
