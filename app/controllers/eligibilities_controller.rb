class EligibilitiesController < ApplicationController
  layout 'inscription'

  CURRENT_REGISTRATION_STEP = 5
  before_action :assert_projet_courant
  authorize_resource :class => false
  before_action do
    set_current_registration_step CURRENT_REGISTRATION_STEP
  end

  def show
    @eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse
    @
    if @projet_courant.locked_at.blank?
      @projet_courant.update_attributes(locked_at: Time.now)
    end
    @page_heading = "Mon résultat"
  end
end
