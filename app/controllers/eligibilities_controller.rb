class EligibilitiesController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant

  def show
    @eligible = @projet_courant.preeligibilite(@projet_courant.annee_fiscale_reference) != :plafond_depasse
    @projet_courant.update_attributes(locked_at: Time.now)
  end
end
