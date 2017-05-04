class DossiersController < ApplicationController
  include ProjetConcern, CsvProperties

  before_action :authenticate_agent!
  before_action :projet_or_dossier
  before_action :assert_projet_courant, except: [:index]

  def index
    @dossiers = Projet.for_agent(current_agent)
    respond_to do |format|
      format.html {
        @page_heading = I18n.t('tableau_de_bord.titre_section')
      }
      format.csv {
        response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
        response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"
        render text: Projet.to_csv(current_agent)
      }
    end
  end

  def affecter_agent
    if @projet_courant.update_attribute(:agent, current_agent)
      flash[:notice] = t('projets.visualisation.projet_affecte')
    else
      flash[:alert] = "Une erreur s'est produite"
    end
    redirect_to dossier_path(@projet_courant)
  end

  def recommander_operateurs
    if request.post?
      if @projet_courant.suggest_operateurs!(suggested_operateurs_params[:suggested_operateur_ids])
        message = I18n.t('recommander_operateurs.succes',
                          count:     @projet_courant.suggested_operateurs.count,
                          demandeur: @projet_courant.demandeur.fullname)
        redirect_to(dossier_path(@projet_courant), notice: message)
      end
    end

    @available_operateurs = @projet_courant.intervenants_disponibles(role: :operateur).to_a
    if @projet_courant.suggested_operateurs.blank? && !request.post?
      @available_operateurs.shuffle!
    end
  end

private

  def export_filename
    "dossiers_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.csv"
  end

  def suggested_operateurs_params
    attributes = params
      .fetch(:projet, {})
      .permit(:suggested_operateur_ids => [])
    attributes[:suggested_operateur_ids] ||= []
    attributes
  end
end
