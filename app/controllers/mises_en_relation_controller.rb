class MisesEnRelationController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  before_action do
    set_current_registration_step Projet::STEP_MISE_EN_RELATION
  end

  def show
    @demande = @projet_courant.demande
    if @demande.eligible_hma_first_step? && @demande.devis_rge && (ENV['ELIGIBLE_HMA'] == 'true')
      render :show_eligible_hma and return
    end      
    if rod_response.scheduled_operation? #prendre @projet_courant.eligible?
      if (@projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse) || @projet_courant.eligibilite == 1
        @operateur = rod_response.operateurs.first
        @action_label = action_label
        render :scheduled_operation
        return
      end
    end
    @demande = @projet_courant.demande
    if pris.blank?
      Rails.logger.error "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement} (projet_id: #{@projet_courant.id})"
      return redirect_to projet_demandeur_departement_non_eligible_path(@projet_courant)
    end
    @pris = pris
    @page_heading = I18n.t("demarrage_projet.mise_en_relation.assignement_pris_titre")
    @action_label = action_label
  end

  def show_eligible_hma
    
  end

  def update
    eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse#prendre @projet_courant.eligible?
    @projet_courant.update_attribute(
      :disponibilite,
      params[:projet][:disponibilite]
    ) if params[:projet].present?

    #j'ai une question sur cette condition
    if (@projet_courant.intervenants.include?(pris) || rod_response.scheduled_operation?) && (eligible ||  @projet_courant.eligibilite == 1)
      operateur = rod_response.operateurs.first
      @projet_courant.contact_operateur!(operateur.reload)
      @projet_courant.commit_with_operateur!(operateur.reload)
      flash[:success] = t("invitations.messages.succes", intervenant: operateur.raison_sociale)
    else
      invitation = @projet_courant.invite_pris!(pris)
      Projet.notify_intervenant_of(invitation) if @projet_courant.eligible?
      flash[:success] = t("invitations.messages.succes", intervenant: pris.raison_sociale)
    end
    @projet_courant.invite_instructeur! rod_response.instructeur
    redirect_to projet_path(@projet_courant)
  rescue => e
    Rails.logger.error e.message
    redirect_to(
      projet_mise_en_relation_path(@projet_courant),
      alert: t("demarrage_projet.mise_en_relation.error")
    )
  end

  private

  def rod_response
    @rod_response ||= if ENV['ROD_ENABLED'] == 'true'
                        Rod.new(RodClient).query_for(@projet_courant)
                      else
                        FakeRodResponse.new(ENV['ROD_ENABLED'])
                      end
  end

  def pris
    if @projet_courant.eligible? || @projet_courant.eligibilite == 1
      rod_response.pris
    else
      rod_response.pris_eie
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
