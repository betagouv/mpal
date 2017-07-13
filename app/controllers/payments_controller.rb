class PaymentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  load_and_authorize_resource

  def new
    @payment = Payment.new
    form_parameters_for_new
  end

  def create
    @payment = Payment.new payment_params
    if @payment.save
      @projet_courant.payment_registry.payments << @payment
      redirect_to dossier_payment_registry_path @projet_courant
    else
      form_parameters_for_error
      render :new
    end
  end

  def edit
    @payment = Payment.find_by_id params[:payment_id]
    form_parameters_for_edit
  end

  def update
    @payment = Payment.new payment_params
    payment_to_update = Payment.find_by_id params[:payment_id]
    if @payment.valid? && payment_to_update.update(payment_params)
      redirect_to dossier_payment_registry_path @projet_courant
    else
      form_parameters_for_error
      render :edit
    end
  end

  def destroy
    payment = @projet_courant.payment_registry.payments.find_by_id params[:payment_id]
    begin
      payment.destroy!
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_validation
    payment = @projet_courant.payment_registry.payments.find_by_id params[:payment_id]
    begin
      payment.update! statut: :a_valider
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to dossier_payment_registry_path @projet_courant
  end

private
  def form_parameters_for_new
    @type_paiement   = nil
    @beneficiaire    = @projet_courant.demandeur.fullname
    @personne_morale = false
  end

  def form_parameters_for_edit
    @type_paiement   = @payment.type_paiement
    @beneficiaire    = @payment.beneficiaire
    @personne_morale = @payment.personne_morale
  end

  def form_parameters_for_error
    @type_paiement   = payment_params[:type_paiement]
    @beneficiaire    = payment_params[:beneficiaire]
    @personne_morale = payment_params[:personne_morale]
  end

  def payment_params
    params.require(:payment).permit(:type_paiement, :beneficiaire, :personne_morale)
  end
end
