class PaymentRegistriesController < ApplicationController
  before_action :assert_projet_courant
  load_and_authorize_resource

  def show
    payments_by_update = @projet_courant.payment_registry.payments.order(updated_at: :desc)
    payments_first = payments_by_update.select { |p| ((can? :modify, p) || (can? :ask_for_modification, p) || (can? :ask_for_instruction, p)) }
    payments_last = payments_by_update.select { |p| ( (can? :read, p) && !((can? :modify, p) || (can? :ask_for_modification, p) || (can? :ask_for_instruction, p)) )}
    @payments = payments_first + payments_last
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
