class EligibilitiesController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  authorize_resource :class => false
  before_action do
    set_current_registration_step Projet::STEP_ELIGIBILITY
  end

  def show
    @eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse
    # fetch_pris
    # if @projet_courant.locked_at.blank?
      # @projet_courant.update_attributes(locked_at: Time.now)
    # end
    @page_heading = "Mon résultat"
  end

private
  def fetch_pris
    if ENV['ROD_ENABLED'] == 'true'
      rod_response = Rod.new(RodClient).query_for(@projet_courant)
      @pris = @eligible ? rod_response.pris : rod_response.pris_eie
    else
      @pris = @projet_courant.intervenants_disponibles(role: :pris).first
    end
  end
end
