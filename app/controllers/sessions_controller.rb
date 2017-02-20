class SessionsController < ApplicationController
  layout 'application'

  before_action :authentifie_sans_redirection

  def new
    if agent_signed_in?
      return redirect_to dossiers_path
    end
  end

  def create
    contribuable = ApiParticulier.new.retrouve_contribuable(param_numero_fiscal, param_reference_avis)
    unless contribuable
      flash.now[:alert] = t('sessions.invalid_credentials')
      return render :new
    end
    session[:numero_fiscal] = param_numero_fiscal
    projet = Projet.find_by(numero_fiscal: param_numero_fiscal)
    if projet
      redirect_to projet
    else
      create_projet_and_redirect
    end
  end

  def create_projet_and_redirect
    constructeur = ProjetConstructeur.new(ApiParticulier.new, ApiBan.new)
    projet = constructeur.initialise_projet(param_numero_fiscal, param_reference_avis)
    if projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: projet)
      notice = t('projets.messages.creation.corps')
      flash[:notice_titre] = t('projets.messages.creation.titre', demandeur_principal: projet.demandeur_principal.fullname)
      redirect_to etape1_recuperation_infos_demarrage_projet_path(projet), notice: notice
    else
      redirect_to new_session_path, alert: t('sessions.erreurs.creation_projet')
    end
  end

  def deconnexion
    reset_session
    redirect_to new_session_path, notice: t('sessions.confirmation_deconnexion')
  end

private
  def param_numero_fiscal
    params[:numero_fiscal].try(:delete, ' ')
  end

  def param_reference_avis
    params[:reference_avis].try(:delete, ' ')
  end
end
