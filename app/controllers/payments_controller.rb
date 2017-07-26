class PaymentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  before_action :find_payment, only: [:edit, :destroy, :ask_for_validation, :ask_for_modification, :ask_for_instruction]
  load_and_authorize_resource

  rescue_from do |exception|
    flash[:alert] = exception.message
    redirect_to dossier_payment_registry_path @projet_courant
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to "/404"
  end

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
  end

  def update
    @payment = Payment.new payment_params
    payment_to_update = Payment.find params[:payment_id]
    if @payment.valid? && payment_to_update.update(payment_params)
      redirect_to dossier_payment_registry_path @projet_courant
    else
      render :edit
    end
  end

  def destroy
    send_mail_for_destruction if @payment.action.to_sym == :a_modifier
    @payment.destroy!
    flash[:notice] = I18n.t("payment.actions.delete.success")
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_validation
    @payment.update! action: :a_valider
    @payment.update! statut: :propose if @payment.statut.to_sym == :en_cours_de_montage
    send_mail_for_validation
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_modification
    @payment.update! action: :a_modifier
    send_mail_for_modification
    redirect_to dossier_payment_registry_path @projet_courant
  end

  def ask_for_instruction
    @payment.update! action: :a_instruire
    @payment.update! statut: :demande if @payment.statut.to_sym == :propose
    send_mail_for_instruction
    redirect_to dossier_payment_registry_path @projet_courant
  end

private
  def payment_params
    params.require(:payment).permit(:type_paiement, :beneficiaire, :personne_morale)
  end

  def find_payment
    @payment = Payment.find params[:payment_id]
  end

  def send_mail_for_destruction
    PaymentMailer.destruction_dossier_paiement(@payment).deliver_later!
  end

  def send_mail_for_validation
    PaymentMailer.validation_dossier_paiement(@payment).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_validation.success")
  end

  def send_mail_for_modification
    if current_user
      PaymentMailer.modification_demandeur(@payment).deliver_later!
    else
      PaymentMailer.modification_instructeur(@payment).deliver_later!
    end
    flash[:notice] = I18n.t("payment.actions.ask_for_modification.success", operateur: @projet_courant.operateur.raison_sociale)
  end

  def send_mail_for_instruction
    PaymentMailer.validation_dossier_paiement(@payment).deliver_later!
    PaymentMailer.accuse_reception_dossier_paiement(@payment).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_instruction.success", instructeur: @projet_courant.invited_instructeur.raison_sociale)
  end
end
