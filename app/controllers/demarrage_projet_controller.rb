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
  end

end
