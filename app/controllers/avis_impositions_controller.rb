class AvisImpositionsController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  before_action :init_view

  def index
  end

  def edit_rfr
    begin
      if params[:projet][:modified_revenu_fiscal_reference] =~ /\d+/
        @projet_courant.update!(modified_revenu_fiscal_reference: params[:projet][:modified_revenu_fiscal_reference])
      else
        @projet_courant.update!(modified_revenu_fiscal_reference: nil)
      end
      redirect_to projet_or_dossier_occupants_path(@projet_courant)
    rescue => e
      flash.now[:alert] = e.message
      render :index
    end
  end

  def new
    @avis_imposition = @projet_courant.avis_impositions.new
  end

  def create
    @avis_imposition = ProjetInitializer.new.initialize_avis_imposition(@projet_courant, avis_imposition_params[:numero_fiscal], avis_imposition_params[:reference_avis])

    if @avis_imposition.blank?
      flash[:alert] = t("sessions.invalid_credentials")
      redirect_to new_projet_or_dossier_avis_imposition_path @projet_courant
    elsif @avis_imposition.is_valid_for_current_year?
      @avis_imposition.save!
      flash[:notice] = "Avis d’imposition ajouté"
      redirect_to projet_or_dossier_avis_impositions_path @projet_courant
    else
      flash[:alert] = t("projets.composition_logement.avis_imposition.messages.annee_invalide", year: 2.years.ago.year)
      redirect_to new_projet_or_dossier_avis_imposition_path @projet_courant
    end
  end

  def destroy
    avis_imposition = @projet_courant.avis_impositions.find(params[:id])
    if avis_imposition != @projet_courant.avis_impositions.first
      avis_imposition.destroy!
      flash[:notice] = "Avis d’imposition supprimé"
    end
    redirect_to projet_or_dossier_avis_impositions_path(@projet_courant)
  end

private
  def init_view
    @page_heading = "Inscription"
  end

  def avis_imposition_params
    (params || {}).require(:avis_imposition)
  end
end

