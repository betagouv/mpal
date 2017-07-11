class AvisImpositionsController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  before_action :init_view
  before_action :authenticate_agent!, only: [:update_project_rfr]
  before_action :check_agent_operateur, only: [:update_project_rfr]
  load_and_authorize_resource

  def index
  end

  def update_project_rfr
    unless @projet_courant.update(modified_revenu_fiscal_reference: modified_revenu_fiscal_reference)
      return render :index
      # ATTENTION PAS MSG ERREUR MAIS CA MARCHE
    end
    redirect_to projet_or_dossier_occupants_path(@projet_courant)
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
    (params || {}).require(:avis_imposition).permit(:numero_fiscal, :reference_avis)
    end

  def modified_revenu_fiscal_reference
    (params || {}).require(:projet).permit(:modified_revenu_fiscal_reference)[:modified_revenu_fiscal_reference]
  end

  def check_agent_operateur
    current_agent && current_agent.operateur?
  end
end
