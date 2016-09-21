class ChoixIntervenantsController < ApplicationController
  def new
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    flash[:notice_titre] = t('projets.intervenants.messages.succes_choix_intervenant_titre')
    redirect_to projet_intervenants_path(@projet_courant), notice: t('projets.intervenants.messages.succes_choix_intervenant')
  end
end
