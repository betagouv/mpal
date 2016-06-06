class SessionsController < ApplicationController
  def new
    
  end

  def create
    service = ApiParticulier.new
    contribuable = service.retrouve_contribuable(params[:numero_fiscal], params[:reference_avis])
    if contribuable
      session[:numero_fiscal] = params[:numero_fiscal]
      projet = Projet.where(numero_fiscal: params[:numero_fiscal]).first
      unless projet 
        facade = ProjetFacade.new(ApiParticulier.new)
        projet = facade.initialise_projet(params[:numero_fiscal], params[:reference_avis])
        projet.save
      end
      redirect_to projet
    else 
      redirect_to new_session_path, alert: t('sessions.invalid_credentials')
    end
  end
end
