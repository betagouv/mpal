class DemarrageProjetController < ApplicationController
  def etape1_recuperation_infos
  end

  def etape1_envoi_infos
    personne_de_confiance = Personne.new
    personne_de_confiance.prenom = params[:personne_de_confiance_prenom]
    personne_de_confiance.nom = params[:personne_de_confiance_nom]
    personne_de_confiance.tel = params[:personne_de_confiance_tel]
    personne_de_confiance.email = params[:personne_de_confiance_email]
    personne_de_confiance.lien_avec_demandeur = params[:personne_de_confiance_lien_avec_demandeur]
    @projet_courant.personne_de_confiance = personne_de_confiance
    if @projet_courant.save
      redirect_to etape2_description_projet_path(@projet_courant)
    else
      render :etape1_recuperation_infos
    end
  end

  def etape2_description_projet
    @demande = @projet_courant.demande || @projet_courant.build_demande
  end

  def etape2_envoi_description_projet
    @projet_courant.demande = Demande.new(demande_params)
    if @projet_courant.demande.save
      redirect_to etape3_infos_complementaires_path(@projet_courant)
    end
  end

  def etape3_infos_complementaires
  end

  private
  def demande_params
    params.require(:demande).permit(:froid, :probleme_deplacement, :handicap, :mauvais_etat, :autres_besoins, :changement_chauffage, :isolation, :adaptation_salle_de_bain, :accessibilite, :travaux_importants, :autres_travaux )
  end
end
