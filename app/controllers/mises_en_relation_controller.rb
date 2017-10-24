class MisesEnRelationController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  before_action do
    set_current_registration_step Projet::STEP_MISE_EN_RELATION
    @not_eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) == :plafond_depasse
  end

  def show
    @demande = @projet_courant.demande
    fetch_intervenants_and_operations
    if @pris.blank?
      Rails.logger.error "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement} (projet_id: #{@projet_courant.id})"
      return redirect_to projet_demandeur_departement_non_eligible_path(@projet_courant)
    end
    @page_heading = I18n.t("demarrage_projet.mise_en_relation.assignement_pris_titre")
    @action_label = action_label
  end

  def update
    begin
      @projet_courant.update_attribute(:disponibilite, params[:projet][:disponibilite]) if params[:projet].present?
      fetch_intervenants_and_operations
      unless @projet_courant.intervenants.include?(@pris) || (@operations.count == 1 && @operateurs.count == 1)
        invitation = @projet_courant.invite_pris!(@pris)
        Projet.notify_intervenant_of(invitation) unless @not_eligible
        flash[:success] = t("invitations.messages.succes", intervenant: @pris.raison_sociale)
      end
      @projet_courant.invite_instructeur! @instructeur
      redirect_to projet_path(@projet_courant)
    rescue => e
      Rails.logger.error e.message
      redirect_to projet_mise_en_relation_path(@projet_courant), alert: t("demarrage_projet.mise_en_relation.error")
    end
  end

private
  def fetch_intervenants_and_operations
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      @pris        = @not_eligible ? rod_response.pris_eie : rod_response.pris
      @instructeur = rod_response.instructeur
      @operateurs  = rod_response.operateurs
      @operations  = rod_response.operations
    else
      @pris        = @projet_courant.intervenants_disponibles(role: :pris).first
      @instructeur = @projet_courant.intervenants_disponibles(role: :instructeur).first
      @operateurs  = []
      @operations  = []
    end
  end

  def action_label
    if needs_mise_en_relation?
      t("demarrage_projet.action")
    else
      t("projets.edition.action")
    end
  end

  def needs_mise_en_relation?
    @projet_courant.contacted_operateur.blank? && @projet_courant.invited_pris.blank?
  end
end
