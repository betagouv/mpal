class SessionsController < ApplicationController
  skip_before_action :authentifie
  def new
  end

  def create
    contribuable = ApiParticulier.new.retrouve_contribuable(params[:numero_fiscal], params[:reference_avis])
    if contribuable
      session[:numero_fiscal] = params[:numero_fiscal]
      projet = ProjetEntrepot.par_numero_fiscal(params[:numero_fiscal])
      if projet
        # redirect_to projet_suivi_path(projet)
        redirect_to projet
      else
        create_projet_and_redirect
      end
    else
      redirect_to new_session_path, alert: t('sessions.invalid_credentials')
    end
  end

  def create_projet_and_redirect
    constructeur = ProjetConstructeur.new(ApiParticulier.new, ApiBan.new)
    projet = constructeur.initialise_projet(params[:numero_fiscal], params[:reference_avis])
    if projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: projet)
      notice = t('projets.messages.creation.corps')
      flash[:notice_titre] = t('projets.messages.creation.titre', usager: projet.usager)
      redirect_to etape1_recuperation_infos_demarrage_projet_path(projet), notice: notice
    else
      redirect_to new_session_path, alert: t('sessions.erreurs.creation_projet')
    end
  end

  def deconnexion
    reset_session
    redirect_to new_session_path, notice: t('sessions.confirmation_deconnexion')
  end

end
