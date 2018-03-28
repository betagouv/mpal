class AvisImpositionsController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  load_and_authorize_resource
  before_action do
    set_current_registration_step Projet::STEP_AVIS_IMPOSITIONS
  end

  def index
    @page_heading = "Mon avis d’imposition"
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
    @page_heading = "Ajouter un avis d’imposition"
  end

  def create
    @avis_imposition = ProjetInitializer.new.initialize_avis_imposition(@projet_courant, avis_imposition_params[:numero_fiscal], avis_imposition_params[:reference_avis])
    if @avis_imposition && @avis_imposition.is_valid_for_current_year? && @avis_imposition.save
      flash[:notice] = "Avis d’imposition ajouté"
      return redirect_to projet_or_dossier_avis_impositions_path(@projet_courant)
    end
    if @avis_imposition.blank?
      @avis_imposition = @projet_courant.avis_impositions.new(avis_imposition_params)
      flash[:alert] = t("sessions.invalid_credentials")
    elsif !@avis_imposition.is_valid_for_current_year?
      flash[:alert] = t("projets.composition_logement.avis_imposition.messages.annee_invalide", year: 2.years.ago.year)
    end
    @page_heading = "Ajouter un avis d’imposition"
    render :new
  end

  def destroy
    avis_imposition = @projet_courant.avis_impositions.find(params[:id])
    if avis_imposition.reference_avis != @projet_courant.reference_avis
      avis_imposition.destroy!
      flash[:notice] = "Avis d’imposition supprimé"
    end
    redirect_to projet_or_dossier_avis_impositions_path(@projet_courant)
  end

private
  def avis_imposition_params
    (params || {}).require(:avis_imposition).permit(:numero_fiscal, :reference_avis)
  end

  def modified_revenu_fiscal_reference
    (params || {}).require(:projet).permit(:modified_revenu_fiscal_reference)[:modified_revenu_fiscal_reference]
  end
end
