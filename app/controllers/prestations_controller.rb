class PrestationsController < ApplicationController

  def create
    # TODO: use projet#select_prestation
    prestation = Prestation.find(params[:prestation_id])
    prestation_projet = ProjetPrestation.find_or_initialize_by(prestation: prestation, projet: @projet_courant)
    prestation_projet.send("#{params[:attributeName]}=", params[:value])

    if prestation_projet.save
      redirect_to projet_demande_path(@projet_courant)
    else
      render text: "KAPUT"
    end
  end

end
