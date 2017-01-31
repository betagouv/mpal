class DemarrageProjetController < ApplicationController
  layout 'inscription'

  def etape1_recuperation_infos
    @projet_courant.personne_de_confiance = Personne.new
    nb_occupants = @projet_courant.occupants.count
    @occupants_a_charge = []
    @projet_courant.nb_occupants_a_charge.times.each do |index|
      @occupants_a_charge << Occupant.new(nom: "Occupant #{index + nb_occupants + 1}")
    end
    @demandeur_principal = @projet_courant.occupants.where(demandeur: true).first
    @action_label = if needs_etape2? then action_label_create else action_label_update end
  end

  def etape1_envoi_infos
    @demandeur_principal = @projet_courant.occupants.where(demandeur: true).first
    if @projet_courant.update_attributes(projet_contacts_params)
      @demandeur_principal.update_attributes(demandeur_principal_civilite_params)
      etape1_redirect_to_next_step
    else
      render :etape1_recuperation_infos
    end
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

  def etape3_choix_intervenant
    @demande = projet_demande
    @is_updating = @projet_courant.intervenants.present?
    @action_label = if @is_updating then action_label_update else action_label_create end
    @operateur = @projet_courant.invited_operateur
    if @projet_courant.prospect?
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @operateurs_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
    end
    if @is_updating && @operateur.present?
      @operateurs_disponibles << @operateur
    end
  end

  def etape3_envoi_choix_intervenant
    begin
      intervenant = Intervenant.find(params[:intervenant])
      @projet_courant.invite_intervenant!(intervenant)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet_courant), notice: t('invitations.messages.succes', intervenant: intervenant.raison_sociale)
    rescue => e
      logger.error e.message
      redirect_to etape3_choix_intervenant_path(@projet_courant), alert: "Une erreur s'est produite lors de l'enregistrement de l'intervenant."
    end
  end

  private

  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def projet_contacts_params
    # civilite n'est pas pris en compte
    params.require(:projet).permit(
      :tel,
      :email,
      personne_de_confiance_attributes: [
        :id,
        :prenom,
        :nom,
        :tel,
        :email,
        :lien_avec_demandeur,
        :civilite,
        :disponibilite
      ]
    )
  end

  def demandeur_principal_civilite_params
    params.fetch(:occupant, {}).permit(:civilite)
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

  def needs_etape2?
    @projet_courant.demande.blank? || ! @projet_courant.demande.complete?
  end

  def needs_etape3?
    @projet_courant.invited_operateur.blank?
  end

  def etape1_redirect_to_next_step
    if needs_etape2?
      redirect_to etape2_description_projet_path(@projet_courant)
    else
      redirect_to projet_path(@projet_courant)
    end
  end

  def etape2_redirect_to_next_step
    if needs_etape3?
      redirect_to etape3_choix_intervenant_path(@projet_courant)
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
