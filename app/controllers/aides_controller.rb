class AidesController < ApplicationController
  def create
    aide = Aide.find(params[:aide_id])
    aide_projet = ProjetAide.find_or_initialize_by(aide_id: aide.id, projet_id: @projet_courant.id)
    aide_projet.montant = params[:montant]

    if aide_projet.save
      redirect_to projet_demande_path(@projet_courant)
    else
      render text: "KAPUT"
    end
  end
end
