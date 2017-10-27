class EngagementOperateurController < ApplicationController
  layout "inscription"

  before_action :assert_projet_courant
  before_action :init_view

  def new
    return redirect_to "/404" unless @projet_courant
    @operateur = Intervenant.find(params[:operateur_id])
  end

  def create
    operateur = Intervenant.find(params[:operateur_id])
    if operateur && (@projet_courant.statut != "prospect" || @projet_courant.operateur.present?)
      return redirect_to projet_path(@projet_courant), flash: { notice: t('projets.intervenants.messages.already_committed', operateur: @projet_courant.operateur) }
    end
    if @projet_courant.commit_with_operateur!(operateur)
      ProjetMailer.notification_engagement_operateur(@projet_courant).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'choix_intervenant', projet: @projet_courant, producteur: @projet_courant.operateur)
      redirect_to projet_path(@projet_courant), flash: { success: t('projets.intervenants.messages.succes_choix_intervenant', operateur: operateur.raison_sociale) }
    else
      redirect_to projet_path(@projet_courant), alert: t('projets.intervenants.messages.erreur_choix_intervenant')
    end
  end

private
  def init_view
    @page_heading = "Mon opérateur-conseil"
  end
end
