class PaymentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  load_and_authorize_resource

  def new
    @payment = Payment.new beneficiaire: @projet_courant.demandeur.fullname
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

  def edit
    @payment = Payment.find_by_id params[:payment_id]
  end

  def update
    @payment = Payment.new payment_params
    payment_to_update = Payment.find_by_id params[:payment_id]
    if @payment.valid? && payment_to_update.update(payment_params)
      redirect_to dossier_payment_registry_path @projet_courant
    else
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
      payment.update! action: :a_valider
      payment.update! statut: :propose if payment.statut.to_sym == :en_cours_de_montage
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_modification
    payment = @projet_courant.payment_registry.payments.find_by_id params[:payment_id]
    begin
      payment.update! action: :a_modifier
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_instruction
    payment = @projet_courant.payment_registry.payments.find_by_id params[:payment_id]
    begin
      payment.update! action: :a_instruire
      payment.update! statut: :demande if payment.statut.to_sym == :propose
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to dossier_payment_registry_path @projet_courant
  end

private
  def payment_params
    params.require(:payment).permit(:type_paiement, :beneficiaire, :personne_morale)
  end
end
