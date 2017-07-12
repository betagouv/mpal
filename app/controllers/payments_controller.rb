class PaymentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  load_and_authorize_resource

  def new
    @payment = Payment.new
    @payment_registry = @projet_courant.payment_registry
  end

  def create
    @payment = Payment.new payment_params
    if @payment.save
      @projet_courant.payment_registry.payments << @payment
      redirect_to dossier_payment_registry_path @projet_courant
    else
      render :new
    end
  end

private
  def payment_params
    params.require(:payment).permit(:type_paiement, :beneficiaire, :personne_morale)
  end
end
