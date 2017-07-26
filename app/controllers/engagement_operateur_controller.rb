class EngagementOperateurController < ApplicationController
  layout 'inscription'

  before_action :assert_projet_courant
  before_action :init_view

  def new
    unless @projet_courant
      return redirect_to "/404"
    end
    @operateur = Intervenant.find(params[:operateur_id])
  end

  def create
    operateur = Intervenant.find(params[:operateur_id])
    if @projet_courant.commit_with_operateur!(operateur)
      flash[:notice_titre] = t('projets.intervenants.messages.succes_choix_intervenant_titre')
      ProjetMailer.notification_engagement_operateur(@projet_courant).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'choix_intervenant', projet: @projet_courant, producteur: @projet_courant.operateur)
      redirect_to projet_path(@projet_courant), notice: t('projets.intervenants.messages.succes_choix_intervenant')
    else
      redirect_to projet_path(@projet_courant), alert: t('projets.intervenants.messages.erreur_choix_intervenant')
    end
  end

private
  def init_view
    @page_heading = 'Inscription'
  end
end
