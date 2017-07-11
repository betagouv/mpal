class PaymentRegistriesController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  load_and_authorize_resource

  def show
    @payment_registry = @projet_courant.payment_registry
  end

  def create
    begin
      @projet_courant.update! payment_registry: PaymentRegistry.create
    rescue => e
      return redirect_to dossier_path(@projet_courant), alert: "Erreur : #{e.message}"
    end

    redirect_to dossier_payment_registry_path(@projet_courant)
  end
end
