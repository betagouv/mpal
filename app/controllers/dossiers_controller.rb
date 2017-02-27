class DossiersController < ApplicationController
  include ProjetConcern

  before_action :authenticate_agent!
  before_action :dossier_ou_projet
  before_action :assert_projet_courant, except: [:index]

  def index
    @dossiers = Projet.for_agent(current_agent)
    @page_heading = "Dossiers"
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
                          demandeur: @projet_courant.demandeur_principal.fullname)
        redirect_to(dossier_path(@projet_courant), notice: message)
      end
    end

    @available_operateurs = @projet_courant.intervenants_disponibles(role: :operateur).to_a
    if @projet_courant.suggested_operateurs.blank? && !request.post?
      @available_operateurs.shuffle!
    end
  end

private

  def suggested_operateurs_params
    attributes = params
      .fetch(:projet, {})
      .permit(:suggested_operateur_ids => [])
    attributes[:suggested_operateur_ids] ||= []
    attributes
  end
end
