class AvisImpositionsController < ApplicationController

  def show
    begin
    @avis_imposition = @projet_courant.avis_impositions.find_by(id: params[:id])
    @contribuable = ApiParticulier.new.retrouve_contribuable(@avis_imposition.numero_fiscal, @avis_imposition.reference_avis)
    rescue
      redirect_to projet_path(@projet_courant), alert: t('projets.composition_logement.avis_imposition.messages.erreur')
    end
  end

  def new
    @avis_imposition = AvisImposition.new
    @occupant = Occupant.find_by(id: params[:occupant_id])
  end

  def create
    constructeur = AvisImpositionConstructeur.new(ApiParticulier.new)
    avis_imposition = constructeur.initialise_avis_imposition(params[:avis_imposition][:numero_fiscal], params[:avis_imposition][:reference_avis])
    if avis_imposition
      avis_imposition.projet = @projet_courant
      avis_imposition.save
      EvenementEnregistreurJob.perform_later(label: 'ajout_avis_imposition', projet: @projet_courant, producteur: avis_imposition)
      redirect_to projet_avis_imposition_path(@projet_courant, avis_imposition)
    else
      redirect_to edit_projet_composition_path(@projet_courant), alert: t('projets.composition_logement.avis_imposition.messages.non_trouve')
    end
  end

  def destroy
    @avis_imposition = AvisImposition.find_by(id: params[:id])
    @avis_imposition.destroy
    redirect_to edit_projet_composition_path(@projet_courant)
  end

end
