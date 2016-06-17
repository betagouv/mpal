class SessionsController < ApplicationController
  def new
    
  end

  def create
    service = ApiParticulier.new
    contribuable = service.retrouve_contribuable(params[:numero_fiscal], params[:reference_avis])
    if contribuable
      session[:numero_fiscal] = params[:numero_fiscal]
      projet = ProjetFacade.recupere_projet(params[:numero_fiscal])
      unless projet 
        facade = ProjetFacade.new(ApiParticulier.new)
        projet = facade.initialise_projet(params[:numero_fiscal], params[:reference_avis])
        projet.save
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
