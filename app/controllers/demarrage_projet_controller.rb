class DemarrageProjetController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
  before_action :init_view

  def mise_en_relation
    @demande = @projet_courant.demande
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris).first
    if @pris_departement.blank?
      raise "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement}"
    end
    @action_label = if needs_mise_en_relation_step? then action_label_create else action_label_update end
  end

  def update_mise_en_relation
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
      redirect_to projet_mise_en_relation_path(@projet_courant), alert: "Une erreur s’est produite lors de l’enregistrement de l’intervenant."
    end
  end

private
  def init_view
    @page_heading = 'Inscription'
  end

  def needs_mise_en_relation_step?
    @projet_courant.invited_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def action_label_create
    t('demarrage_projet.action')
  end

  def action_label_update
    t('projets.edition.action')
  end
end
