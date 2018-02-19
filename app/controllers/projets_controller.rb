class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :assert_projet_courant, except: [:new, :create]
  before_action :redirect_to_project_if_exists, only: [:new, :create]
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:new, :create]

  def show
    # TODO flash à déplacer sur l’accueil
    return redirect_to_project_if_exists if @projet_courant.invitations.blank?
    if @projet_courant.invited_pris && @projet_courant.pris_suggested_operateurs.blank?
      pris_name = @projet_courant.invited_pris.raison_sociale
      flash[:notice_html] = "#{pris_name} ne vous a pas encore proposé d’opérateur-conseil. <a href=\"#{new_projet_or_dossier_message_path}\">Contacter #{pris_name}</a>."
    end
    render_show
  end

  def index
    @page_heading = I18n.t('tableau_de_bord.titre_section')
    render "projets/dashboard_mandataire"
  end

  def new
    if agent_signed_in?
      return redirect_to dossiers_path
    end
    @projet = Projet.new
    @page_heading = "Je commence ma démarche"
  end

  def create
    @page_heading = "Je commence ma démarche"

    @projet = Projet.where(numero_fiscal: param_numero_fiscal, reference_avis: param_reference_avis).first
    if @projet
      if @projet.demandeur_user
        if  @projet.demandeur_user.active_for_authentication?
          return redirect_to new_user_session_path, alert: t("sessions.user_exists")
        else
          if !@projet.demandeur_user.confirmed? && (@projet.demandeur_user.confirmation_sent_at + Devise.confirm_within) < Time.now
            begin
              uid = @projet.demandeur_user.id
              ProjetsUser.where(:user_id => @projet.demandeur_user.id).first.delete
              User.find(uid).delete
              @projet.update(:locked_at => nil)
            rescue
              return redirect_to root_path, alert: t("sessions.signed_up_but_unconfirmed")
            end
          else
            return redirect_to root_path, alert: t("sessions.signed_up_but_unconfirmed")
          end
          if session[:project_id] != @projet.id
            session[:project_id] = @projet.id
          end

          return redirect_to_next_step(@projet)
        end
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
      return render :new
    end

    contribuable = ApiParticulier.new(param_numero_fiscal, param_reference_avis).retrouve_contribuable
    unless contribuable
      flash.now[:alert] = t('sessions.invalid_credentials')
      return render :new
    end

    unless "1" == params[:proprietaire]
      flash.now[:alert] = t('sessions.erreur_proprietaire_html', anil: view_context.link_to('Anil.org', 'https://www.anil.org/')).html_safe
      return render :new
    end

    unless @projet.avis_impositions.map(&:is_valid_for_current_year?).all?
      flash.now[:alert] =  I18n.t("projets.composition_logement.avis_imposition.messages.annee_invalide", year: 2.years.ago.year)
      return render :new
    end

    if @projet.save
      EvenementEnregistreurJob.perform_later(label: 'creation_projet', projet: @projet)
      session[:project_id] = @projet.id
      return redirect_to projet_demandeur_path(@projet), notice: t('projets.messages.creation.corps')
    end

    render :new, alert: t('sessions.erreur_creation_projet')
  end

private
  def param_numero_fiscal
    params[:projet][:numero_fiscal].to_s.gsub(/\D+/, '')
  end

  def param_reference_avis
    params[:projet][:reference_avis].to_s.gsub(/\W+/, '').upcase
  end

  def redirect_to_next_step(projet)
    projet.update(:actif => 1)
    if projet.demandeur.blank?
      redirect_to projet_demandeur_path(projet)
    elsif @projet.locked_at && @projet.demandeur_user.blank?
      redirect_to new_user_registration_path
    else
      redirect_to projet
    end
  end
end
