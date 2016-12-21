class DemarrageProjetController < ApplicationController
  layout "minimal"

  def etape1_recuperation_infos
    @projet_courant.personne_de_confiance = Personne.new
    nb_occupants = @projet_courant.occupants.count
    @occupants_a_charge = []
    @projet_courant.nb_occupants_a_charge.times.each do |index|
      @occupants_a_charge << Occupant.new(nom: "Occupant #{index + nb_occupants + 1}")
    end
  end

  def etape1_envoi_infos
    if @projet_courant.update_attributes(projet_contacts_params)
      redirect_to etape2_description_projet_path(@projet_courant)
    else
      render :etape1_recuperation_infos
    end
  end

  def etape2_description_projet
    @demande = projet_demande
  end

  def etape2_envoi_description_projet
    @projet_courant.demande = projet_demande
    if etape2_valide?
      @projet_courant.demande.update_attributes(demande_params)
      redirect_to etape3_choix_intervenant_path(@projet_courant)
    else
      redirect_to etape2_description_projet_path(@projet_courant), alert: t('demarrage_projet.etape2_description_projet.erreurs.besoin_obligatoire')
    end
  end

  def etape3_choix_intervenant
    @demande = projet_demande
    if @projet_courant.prospect?
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @operateurs_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
    end
  end

  def etape3_envoi_choix_intervenant
    @projet_courant.disponibilite = params[:disponibilite]

    @intervenant = Intervenant.find(params[:intervenant_id])
    @invitation = Invitation.new(projet: @projet_courant, intervenant: @intervenant)
    if @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_later!
      ProjetMailer.notification_invitation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: @projet_courant, producteur: @invitation)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet_courant), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      render :etape3_choix_operateur
    end
  end

  private
  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def projet_contacts_params
    # manque civilite
    params.require(:projet).permit(:tel, :email, :disponibilite, personne_de_confiance_attributes: [:id, :prenom, :nom, :tel, :email, :lien_avec_demandeur, :civilite, :disponibilite])
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
    :date_achevement_15_ans)
  end

  def etape2_valide?
    result = false
    demande_params.each_pair do |attribute,value|
      result = result || value == "1"
    end
    result
  end
end
