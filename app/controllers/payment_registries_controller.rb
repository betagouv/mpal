class PaymentRegistriesController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  before_action :redirect_unless_agent_operateur, only: :create

  def show
    @payment_registry = @projet_courant.payment_registry
    if @payment_registry.blank?
      redirect_to projet_or_dossier_path(@projet_courant), alert: t("sessions.access_forbidden")
    end
  end

  def create
    if @projet_courant.payment_registry
      return redirect_to dossier_payment_registry_path(@projet_courant)
    end

    project_not_transmited_yet = Projet::STATUSES.split(:transmis_pour_instruction).first.include? @projet_courant.statut.to_sym
    if project_not_transmited_yet
      return redirect_to dossier_path(@projet_courant), alert: "Erreur : Vous ne pouvez ajouter un registre de paiement que si le projet a été transmis pour instruction"
    end

    begin
      @projet_courant.update! payment_registry: PaymentRegistry.create
    rescue => e
      return redirect_to dossier_path(@projet_courant), alert: "Erreur : #{e.message}"
    end

    redirect_to dossier_payment_registry_path(@projet_courant)
  end

private
  def redirect_unless_agent_operateur
    unless current_agent.try(:operateur?)
      flash[:alert] = t("sessions.access_forbidden")
      if @projet_courant.payment_registry.present?
        redirect_to dossier_payment_registry_path(@projet_courant)
      else
        redirect_to dossier_path(@projet_courant)
      end
    end
  end
end
