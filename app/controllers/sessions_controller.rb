class SessionsController < ApplicationController
  skip_before_action :authenticate
  def new
    
  end

  def create
    service = ApiParticulier.new
    contribuable = service.retrouve_contribuable(params[:numero_fiscal], params[:reference_avis])
    if contribuable
      session[:numero_fiscal] = params[:numero_fiscal]
      projet = ProjetEntrepot.par_numero_fiscal(params[:numero_fiscal])
      unless projet 
        facade = ProjetFacade.new(service, ApiBan.new)
        projet = facade.initialise_projet(params[:numero_fiscal], params[:reference_avis])
        projet.save
        EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet_id: projet.id)
        notice = t('projets.messages.creation.corps')
        flash[:notice_titre] = t('projets.messages.creation.titre', usager: projet.usager)
      end
      if projet
        redirect_to projet, notice: notice
      else
        redirect_to new_session_path, alert: t('sessions.erreur_generique')
      end
    else 
      redirect_to new_session_path, alert: t('sessions.invalid_credentials')
    end
  end
end
