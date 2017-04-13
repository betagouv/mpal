class DemarrageProjetController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
  before_action :init_view

  def demandeur
    if request.post? && demandeur_save
      return demandeur_redirect_to_next_step
    end

    @projet_courant.personne ||= Personne.new
    @demandeur = @projet_courant.demandeur_principal
    @declarants = @projet_courant.occupants.declarants.collect { |o| [ o.fullname, o.id ] }
    @action_label = if needs_etape2? then action_label_create else action_label_update end
  end

  def etape2_description_projet
    @demande = projet_demande
    @action_label = if needs_etape3? then action_label_create else action_label_update end
  end

  def etape2_envoi_description_projet
    @projet_courant.demande = projet_demande
    if demande_params_valid?
      @projet_courant.demande.update_attributes(demande_params)
      etape2_redirect_to_next_step
    else
      redirect_to etape2_description_projet_path(@projet_courant), alert: t('demarrage_projet.etape2_description_projet.erreurs.besoin_obligatoire')
    end
  end

  def etape3_mise_en_relation
    @demande = projet_demande
    @pris_departement = @projet_courant.intervenants_disponibles(role: :pris).first
    if @pris_departement.blank?
      raise "Il n’y a pas de PRIS disponible pour le département #{@projet_courant.departement}"
    end
    @action_label = if needs_etape3? then action_label_create else action_label_update end
  end

  def etape3_envoi_mise_en_relation
    begin
      @projet_courant.update_attribute(:disponibilite, params[:projet][:disponibilite])
      intervenant = Intervenant.find_by_id(params[:intervenant])
      unless @projet_courant.intervenants.include? intervenant
        @projet_courant.invite_intervenant!(intervenant)
        flash[:notice_titre] = t('invitations.messages.succes_titre')
        flash[:notice] = t('invitations.messages.succes', intervenant: intervenant.raison_sociale)
      end
      redirect_to projet_path(@projet_courant)
    rescue => e
      logger.error e.message
      redirect_to etape3_mise_en_relation_path(@projet_courant), alert: "Une erreur s’est produite lors de l’enregistrement de l’intervenant."
    end
  end

private
  def init_view
    @page_heading = 'Inscription'
  end

  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def projet_contacts_params
    params.require(:projet).permit(
      :civilite,
      :tel,
      :email,
    )
  end

  def projet_personne_params
    params.require(:projet).permit(
      personne_attributes: [
        :id,
        :prenom,
        :nom,
        :tel,
        :email,
        :lien_avec_demandeur,
        :civilite
      ]
    )
  end

  def demandeur_principal_params
    params.fetch(:demandeur_principal, {}).permit(:civilite)
  end

  def demande_params
    params.require(:demande).permit(
      :changement_chauffage,
      :froid,
      :probleme_deplacement,
      :accessibilite,
      :hospitalisation,
      :adaptation_salle_de_bain,
      :autre,
      :travaux_fenetres,
      :travaux_isolation,
      :travaux_chauffage,
      :travaux_adaptation_sdb,
      :travaux_monte_escalier,
      :travaux_amenagement_ext,
      :travaux_autres,
      :complement,
      :annee_construction,
      :ptz,
      :date_achevement_15_ans
    )
  end

  def demande_params_valid?
    demande_params.values.include?('1')
  end

  def demandeur_save
    begin
      @projet_courant.adresse_postale = ProjetInitializer.new.precise_adresse(
        params[:projet][:adresse_postale],
        previous_value: @projet_courant.adresse_postale,
        required: true
      )

      @projet_courant.adresse_a_renover = ProjetInitializer.new.precise_adresse(
        params[:projet][:adresse_a_renover],
        previous_value: @projet_courant.adresse_a_renover,
        required: false
      )
    rescue => e
      flash.now[:alert] = e.message
      return false
    end

    @projet_courant.assign_attributes(projet_contacts_params)
    if "1" == params[:contact]
      @projet_courant.assign_attributes(projet_personne_params)
    else
      if @projet_courant.personne.present?
        personne = @projet_courant.personne
        @projet_courant.update_attribute(:personne_id, nil)
        personne.destroy!
      else
        @projet_courant.personne = nil
      end
    end
    unless @projet_courant.save
      return false
    end

    demandeur_id = params[:projet][:demandeur_id]
    if demandeur_id.present?
      return define_demandeur(demandeur_id)
    end

    true
  end

  def define_demandeur(demandeur_id)
    @demandeur = @projet_courant.change_demandeur(demandeur_id)
    @demandeur.assign_attributes(demandeur_principal_params)
    unless @demandeur.save
      flash.now[:alert] = t('demarrage_projet.demandeur.erreurs.enregistrement_demandeur')
      return false
    end
    true
  end

  def needs_etape2?
    @projet_courant.demande.blank? || ! @projet_courant.demande.complete?
  end

  def needs_etape3?
    @projet_courant.invited_operateur.blank? && @projet_courant.invited_pris.blank?
  end

  def demandeur_redirect_to_next_step
    if needs_etape2?
      redirect_to projet_avis_impositions_path(@projet_courant)
    else
      redirect_to projet_path(@projet_courant)
    end
  end

  def etape2_redirect_to_next_step
    if needs_etape3?
      redirect_to etape3_mise_en_relation_path(@projet_courant)
    else
      redirect_to projet_path(@projet_courant)
    end
  end

  def action_label_create
    t('demarrage_projet.action')
  end

  def action_label_update
    t('projets.edition.action')
  end
end
