class MisesEnRelationController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def show
    @demande = @projet_courant.demande
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris).first
    if @pris_departement.blank?
      raise "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement}"
    end
    @page_heading = 'Inscription'
    @action_label = if needs_mise_en_relation? then action_label_create else action_label_update end
  end

  def update
    begin
      @projet_courant.update_attribute(:disponibilite, params[:projet][:disponibilite])
      intervenant = Intervenant.find_by_id(params[:intervenant])
      unless @projet_courant.intervenants.include? intervenant
        @projet_courant.invite_intervenant!(intervenant)
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

  def needs_mise_en_relation?
    @projet_courant.invited_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def action_label_create
    t('demarrage_projet.action')
  end

  def action_label_update
    t('projets.edition.action')
  end
end
