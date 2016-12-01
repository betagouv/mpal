class DemarrageProjetController < ApplicationController
  def etape1_recuperation_infos
    @projet_courant.personne_de_confiance = Personne.new
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
      redirect_to etape3_infos_complementaires_path(@projet_courant)
    else
      redirect_to etape2_description_projet_path(@projet_courant), alert: t('demarrage_projet.etape2_description_projet.erreurs.besoin_obligatoire')
    end
  end


  def etape3_infos_complementaires
    @demande = projet_demande
  end

  def etape3_envoi_infos_complementaires
    @projet_courant.demande = projet_demande
    if @projet_courant.demande.update_attributes(demande_infos_complementaires_params)
      redirect_to etape4_choix_operateur_path(@projet_courant)
    end
  end

  def etape4_choix_operateur
    if @projet_courant.prospect?
      @pris_departement = @projet_courant.intervenants_disponibles(role: :pris)
      @operateurs_disponibles = @projet_courant.intervenants_disponibles(role: :operateur).shuffle
    end
  end

  def etape4_envoi_choix_operateur
    @intervenant = Intervenant.find(params[:intervenant_id])
    @invitation = Invitation.new(projet: @projet_courant, intervenant: @intervenant)
    if @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_later!
      ProjetMailer.notification_invitation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: @projet_courant, producteur: @invitation)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet_courant), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      render :etape4_choix_operateur
    end
  end

  private
  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def projet_contacts_params
    params.require(:projet).permit(:tel, :email, :disponibilite, personne_de_confiance_attributes: [:id, :prenom, :nom, :tel, :email, :lien_avec_demandeur, :civilite, :disponibilite])
  end

  def demande_params
    params.require(:demande).permit(:froid, :probleme_deplacement, :handicap, :mauvais_etat, :autres_besoins, :changement_chauffage, :isolation, :adaptation_salle_de_bain, :accessibilite, :travaux_importants, :autres_travaux )
  end

  def etape2_valide?
    result = false
    return true if demande_params[:autres_besoins].present? || demande_params[:autres_travaux].present?
    demande_params.each_pair do |attribute,value|
      result = result || value == "1"
    end
    result
  end

  def demande_infos_complementaires_params
    params.require(:demande).permit(:ptz, :devis, :travaux_engages, :annee_construction, :maison_individuelle)
  end
end
