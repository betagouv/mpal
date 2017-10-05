class PaymentsController < ApplicationController
  before_action :assert_projet_courant
  before_action :find_payment, only: [:edit, :destroy, :ask_for_validation, :ask_for_modification, :ask_for_instruction]
  load_and_authorize_resource

  rescue_from do |exception|
    flash[:alert] = exception.message
    redirect_to projet_or_dossier_payments_path @projet_courant
  end

  rescue_from ActiveRecord::RecordNotFound do
    #TODO handle exceptions in action
    redirect_to "/404"
  end

  def index
    payments_by_update = @projet_courant.payments.order(updated_at: :desc)
    payments_first = payments_by_update.select { |p| ((can? :modify, p) || (can? :ask_for_modification, p) || (can? :ask_for_instruction, p)) }
    payments_last = payments_by_update.select { |p| ( (can? :read, p) && !((can? :modify, p) || (can? :ask_for_modification, p) || (can? :ask_for_instruction, p)) )}
    @payments = payments_first + payments_last
  end

  def new
    @payment = Payment.new beneficiaire: @projet_courant.demandeur.fullname
  end

  def create
    @payment = Payment.new payment_params
    @payment.projet = @projet_courant
    if @payment.save
      redirect_to dossier_payments_path @projet_courant
    else
      render :new
    end
  end

  def edit
  end

  def update
    @payment = Payment.new payment_params
    payment_to_update = Payment.find params[:payment_id]
    payment_to_update.assign_attributes payment_params
    if @payment.valid? && payment_to_update.save
      redirect_to dossier_payments_path @projet_courant
    else
      render :edit
    end
  end

  def destroy
    send_mail_for_destruction if @payment.action?(:a_modifier)
    @payment.destroy!
    flash[:notice] = I18n.t("payment.actions.delete.success")
    redirect_to dossier_payments_path @projet_courant
  end

  def ask_for_validation
    @payment.ask_for_validation
    send_mail_for_validation
    redirect_to dossier_payments_path @projet_courant
  end

  def ask_for_modification
    @payment.ask_for_modification
    send_mail_for_modification
    redirect_to projet_or_dossier_payments_path @projet_courant
  end

  def ask_for_instruction
    @payment.statut?(:propose) ? send_mail_for_instruction : send_mail_for_correction_after_instruction
    @payment.ask_for_instruction
    redirect_to projet_or_dossier_payments_path @projet_courant
  end

  def send_in_opal
    @payment = @projet_courant.payments.where(id: params[:payment_id]).first
    begin
      opal_api.update_projet_with_dossier_paiement!(@projet_courant, @payment)
      @payment.send_in_opal
      redirect_to(dossier_payments_path(@projet_courant), notice: t('payment.add_to_opal.messages.success', id_opal: @projet_courant.opal_numero))
    rescue => e
      redirect_to(dossier_payments_path(@projet_courant), alert: t('payment.add_to_opal.messages.error', message: e.message))
    end
  end

  private
  def opal_api
    @opal_api ||= Opal.new(OpalClient)
  end

  def payment_params
    parameters = params.require(:payment).permit(:type_paiement, :beneficiaire, :procuration)
    if parameters[:procuration] != "true"
      parameters[:beneficiaire] = @projet_courant.demandeur.fullname
    end
    parameters
  end

  def find_payment
    @payment = Payment.find params[:payment_id]
  end

  def send_mail_for_destruction
    PaymentMailer.destruction(@payment).deliver_later!
  end

  def send_mail_for_validation
    PaymentMailer.demande_validation(@payment).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_validation.success")
  end

  def send_mail_for_modification
    is_from_user =  current_user.present?
    PaymentMailer.demande_modification(@payment, is_from_user).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_modification.success", operateur: @projet_courant.operateur.raison_sociale)
  end

  def send_mail_for_instruction
    PaymentMailer.depot(@payment, @projet_courant.invited_instructeur).deliver_later!
    PaymentMailer.depot(@payment, @projet_courant.operateur).deliver_later!
    PaymentMailer.accuse_reception_depot(@payment).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_instruction.success", instructeur: @projet_courant.invited_instructeur.raison_sociale)
  end

  def send_mail_for_correction_after_instruction
    PaymentMailer.correction_depot(@payment, @projet_courant.invited_instructeur).deliver_later!
    PaymentMailer.correction_depot(@payment, @projet_courant.operateur).deliver_later!
    PaymentMailer.accuse_reception_correction_depot(@payment).deliver_later!
    flash[:notice] = I18n.t("payment.actions.ask_for_instruction.success", instructeur: @projet_courant.invited_instructeur.raison_sociale)
  end
end
