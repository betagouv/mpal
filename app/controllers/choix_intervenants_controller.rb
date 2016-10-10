class ChoixIntervenantsController < ApplicationController
  def new
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    @projet_courant.operateur = Intervenant.find(params[:intervenant_id])
    @projet_courant.statut = :en_cours
    if @projet_courant.save
      flash[:notice_titre] = t('projets.intervenants.messages.succes_choix_intervenant_titre')
      EvenementEnregistreurJob.perform_later(label: 'choix_intervenant', projet: @projet_courant, producteur: @projet_courant.operateur)
      redirect_to projet_intervenants_path(@projet_courant), notice: t('projets.intervenants.messages.succes_choix_intervenant')
    else
      redirect_to projet_intervenants_path(@projet_courant), alert: t('projets.intervenants.messages.erreur_choix_intervenant')
    end
  end
end
