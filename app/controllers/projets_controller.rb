class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :assert_projet_courant, except: [:new, :create]
  before_action :redirect_to_project_if_exists, only: [:new, :create]
  before_action :redirect_if_no_account, only: :show

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
    @page_heading = "Création de dossier"

    @projet = Projet.where(numero_fiscal: param_numero_fiscal, reference_avis: param_reference_avis).first
    if @projet
      if @projet.user
        return redirect_to new_user_session_path, alert: t("sessions.user_exists")
      end
      if session[:project_id] != @projet.id
        session[:project_id] = @projet.id
      end
      return redirect_to_next_step(@projet)
    end

    begin
      @projet = ProjetInitializer.new.initialize_projet(param_numero_fiscal, param_reference_avis)
    rescue => e
      @projet = Projet.new(params[:projet].permit(:numero_fiscal, :reference_avis))
      flash.now[:alert] =  "Erreur : #{e.message}"
      return render :new, layout: "creation_dossier"
    end

    contribuable = ApiParticulier.new(param_numero_fiscal, param_reference_avis).retrouve_contribuable
    unless contribuable
      flash.now[:alert] = t('sessions.invalid_credentials')
      return render :new, layout: 'creation_dossier'
    end

    unless "1" == params[:proprietaire]
      flash.now[:alert] = t('sessions.erreur_proprietaire_html', anil: view_context.link_to('Anil.org', 'https://www.anil.org/')).html_safe
      return render :new, layout: 'creation_dossier'
    end

    unless @projet.avis_impositions.map(&:is_valid_for_current_year?).all?
      flash.now[:alert] =  I18n.t("projets.composition_logement.avis_imposition.messages.annee_invalide", year: 2.years.ago.year)
      return render :new, layout: "creation_dossier"
    end

    if @projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: @projet)
      session[:project_id] = @projet.id
      return redirect_to projet_demandeur_path(@projet), notice: t('projets.messages.creation.corps')
    end

    render :new, layout: "creation_dossier", alert: t('sessions.erreur_creation_projet')
  end

private
  def param_numero_fiscal
    params[:projet][:numero_fiscal].to_s.gsub(/\D+/, '')
  end

  def param_reference_avis
    params[:projet][:reference_avis].to_s.gsub(/\W+/, '').upcase
  end

  def redirect_if_no_account
    if @projet_courant.locked_at.nil?
      return redirect_to projet_demandeur_path(@projet_courant), alert: t('sessions.access_forbidden')
    elsif @projet_courant.locked_at && @projet_courant.user.blank?
      return redirect_to projet_eligibility_path(@projet_courant), alert: t('sessions.access_forbidden')
    elsif @projet_courant.user && @projet_courant.invitations.blank?
      return redirect_to projet_mise_en_relation_path(@projet_courant), alert: t('sessions.access_forbidden')
    end
  end

  def redirect_to_next_step(projet)
    if projet.demandeur.blank?
      redirect_to projet_demandeur_path(projet)
    elsif @projet.locked_at && @projet.user.blank?
      redirect_to projet_eligibility_path(projet)
    else
      redirect_to projet
    end
  end
end
