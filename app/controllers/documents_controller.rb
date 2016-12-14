class DocumentsController < ApplicationController
  def create
    @document = @projet_courant.documents.build
    @document.fichier = params[:fichier_document]
    @document.label = params[:label_document]
    if @document.save
      redirect_to projet_demande_path(@projet_courant)
    else
      render 'projets/demande2'
      # redirect_to projet_demande_path(@projet_courant), alert: t('projets.demande.messages.erreur_depot_document')
    end
  end

  def destroy
    @document = @projet_courant.documents.where(id: params[:id]).first
    @document.destroy
    redirect_to projet_path(@projet_courant), notice: t('projets.demande.messages.succes_suppression_document')
  end

end
