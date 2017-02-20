class DocumentsController < ApplicationController
  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie

  def create
    @document = @projet_courant.documents.build
    @document.fichier = params[:fichier_document]
    @document.label = if params[:label_document].present? then params[:label_document] else @document.fichier.filename end
    if @document.save
      redirect_to dossier_demande_path(@projet_courant), notice: t('projets.demande.messages.succes_depot_document')
    else
      redirect_to dossier_demande_path(@projet_courant), alert: t('projets.demande.messages.erreur_depot_document')
    end
  end

  def destroy
    @document = @projet_courant.documents.where(id: params[:id]).first
    @document.destroy
    redirect_to dossier_path(@projet_courant), notice: t('projets.demande.messages.succes_suppression_document')
  end
end
