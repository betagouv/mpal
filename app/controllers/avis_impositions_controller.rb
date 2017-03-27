class AvisImpositionsController < ApplicationController
  layout "inscription"

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
  before_action :init_view

  def index
  end

  def new
    init_view
  end

  def create
    avis_imposition = @projet_courant.avis_impositions.new(strong_params_hash)
    @avis_imposition = ProjetInitializer.new.initialize_avis_imposition(@projet_courant, avis_imposition.numero_fiscal, avis_imposition.reference_avis)
    unless @avis_imposition
      flash.now[:alert] = t("sessions.invalid_credentials")
      return render :new
    end
    unless @avis_imposition.save
      return render :new
    end
    flash[:notice] = "Avis d’imposition ajouté"
    redirect_to projet_avis_impositions_path(projet_id: @projet_courant)
  end

  def destroy
    @avis_imposition = @projet_courant.avis_impositions.find(params[:id]).destroy!
    flash[:notice] = "Avis d’imposition supprimé"
    redirect_to projet_avis_impositions_path(@projet_courant)
  end

private
  def init_view
    @page_heading = "Inscription"
  end

  def strong_params_hash
    (params || {}).require(:avis_imposition).permit(strong_params)
  end

  def strong_params
    %w(numero_fiscal reference_avis)
  end

  def param_numero_fiscal
    params[:avis_imposition][:numero_fiscal].try(:delete, ' ')
  end

  def param_reference_avis
    params[:avis_imposition][:reference_avis].try(:delete, ' ')
  end
end

