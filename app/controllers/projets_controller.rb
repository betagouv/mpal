class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :projet_or_dossier
  before_action :assert_projet_courant, except: [:new, :create]
  before_action :authentifie, except: [:new, :create]
  before_action :authentifie_sans_redirection


  def show
    render_show
  end

  def new
    if agent_signed_in?
      return redirect_to dossiers_path
    end
    @projet = Projet.new
    @page_heading = "Création de dossier"
    render layout: "creation_dossier"
  end

  def create
    unless "1" == params[:proprietaire]
      flash.now[:alert] = t('sessions.erreur_proprietaire_html', anil: view_context.link_to('Anil.org', 'https://www.anil.org/')).html_safe
      return render :new, layout: 'creation_dossier'
    end
    contribuable = ApiParticulier.new(param_numero_fiscal, param_reference_avis).retrouve_contribuable
    unless contribuable
      flash.now[:alert] = t('sessions.invalid_credentials')
      return render :new, layout: 'creation_dossier'
    end
    projet = Projet.where(numero_fiscal: params[:numero_fiscal], reference_avis: params[:reference_avis]).first
    if projet
      if session[:project_id] != projet.id
        session[:project_id] = projet.id
      end
      redirect_to_next_step(projet)
    else
      create_projet_and_redirect
    end


    @page_heading = "Création de dossier"
    # render layout: "creation_dossier"
  end

  def deconnexion
    reset_session
    render :new, notice: t('sessions.confirmation_deconnexion')
  end

private

  def param_numero_fiscal
    params[:numero_fiscal].to_s.gsub(/\D+/, '')
  end

  def param_reference_avis
    params[:reference_avis].to_s.gsub(/\W+/, '').upcase
  end

  def create_projet_and_redirect
    projet = ProjetInitializer.new.initialize_projet(param_numero_fiscal, param_reference_avis)
    if projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: projet)
      notice = t('projets.messages.creation.corps')
      flash[:notice_titre] = t('projets.messages.creation.titre')
      session[:project_id] = projet.id
      redirect_to projet_demandeur_path(projet), notice: notice
    else
      redirect_to new_session_path, alert: t('sessions.erreur_creation_projet')
    end
  end

  def redirect_to_next_step(projet)
    if projet.demandeur.blank?
      redirect_to projet_demandeur_path(projet)
    else
      redirect_to projet
    end
  end

end
