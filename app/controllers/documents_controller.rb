class DocumentsController < ApplicationController
  def create
    document = @projet_courant.documents.build
    document.fichier = params[:fichier_document]
    if document.save
      redirect_to projet_demande_path(@projet_courant), notice: t('projets.demande.messages.succes_depot_document')
    else
      redirect_to projet_demande_path(@projet_courant), warning: t('projets.demande.messages.erreur_depot_document')
    end 
  end
end
