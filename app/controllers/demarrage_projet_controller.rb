class DemarrageProjetController < ApplicationController
  def etape1_recuperation_infos
    # définir projet courant ici car le formulaire le renvoi pas ?
  end

  def etape1_envoi_infos
    @projet_courant.personne_de_confiance = projet_personne_de_confiance
    puts "--------valeur de p courant  ------ #{@projet_courant}------------------"
    @projet_courant.update_attributes(projet_moyen_contact_params)
    puts "---------- update du tel et mail ------- "
    if @projet_courant.personne_de_confiance.update_attributes(projet_personne_de_confiance_params)
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
    if @projet_courant.demande.update_attributes(demande_params)
      redirect_to etape3_infos_complementaires_path(@projet_courant)
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
  end

  private
  def projet_demande
    @projet_courant.demande || @projet_courant.build_demande
  end

  def projet_personne_de_confiance
    @projet_courant.build_personne_de_confiance
    puts "-------- valeur p confiance #{@projet_courant.personne_de_confiance} ----- "
  end

  def projet_moyen_contact_params
    params.permit(:tel, :email)
  end

  def projet_personne_de_confiance_params
    params.permit(:projet_personnes_personne_de_confiance_prenom, :projet_personnes_personne_de_confiance_nom, :projet_personnes_personne_de_confiance_tel, :projet_personnes_personne_de_confiance_email, :projet_personnes_personne_de_confiance_lien_avec_demandeur)
  end

  def demande_params
    params.require(:demande).permit(:froid, :probleme_deplacement, :handicap, :mauvais_etat, :autres_besoins, :changement_chauffage, :isolation, :adaptation_salle_de_bain, :accessibilite, :travaux_importants, :autres_travaux )
  end

  def demande_infos_complementaires_params
    params.require(:demande).permit(:ptz, :devis, :travaux_engages, :annee_construction, :maison_individuelle)
  end
end
