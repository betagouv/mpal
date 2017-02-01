class ChoixIntervenantsController < ApplicationController
  layout 'inscription'

  def new
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    operateur = Intervenant.find(params[:intervenant_id])
    if @projet_courant.commit_with_operateur!(operateur)
      flash[:notice_titre] = t('projets.intervenants.messages.succes_choix_intervenant_titre')
      ProjetMailer.notification_choix_intervenant(@projet_courant).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'choix_intervenant', projet: @projet_courant, producteur: @projet_courant.operateur)
      redirect_to projet_path(@projet_courant), notice: t('projets.intervenants.messages.succes_choix_intervenant')
    else
      redirect_to projet_path(@projet_courant), alert: t('projets.intervenants.messages.erreur_choix_intervenant')
    end
  end
end
