class IntervenantsController < ApplicationController
  before_action :assert_projet_courant
  authorize_resource :class => false

  def index
    @page_heading = "Contacts"
    @pris         = @projet_courant.invited_pris
    @operateur    = @projet_courant.operateur
    @instructeur  = @projet_courant.invited_instructeur
    @demandeur    = @projet_courant.demandeur
    @personne     = @projet_courant.personne
    if @pris.nil?
      @pris = Rod.new(RodClient).query_for(@projet_courant).pris
    end
  end
end
