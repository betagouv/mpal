class DocumentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  before_action :assert_file_present, only: :create
  load_and_authorize_resource

  def create
    begin
      @document = Document.create! fichier: params[:fichier], type_piece: params[:type_piece], projet: @projet_courant
      flash[:notice] = t("document.messages.create.success")
    rescue => e
      Rails.logger.error "[DocumentsController] create action failed : #{e.message}"
      flash[:alert] = t("document.messages.create.error")
    end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

  def destroy
    begin
      @document = @projet_courant.documents.find params[:id]
      @document.destroy!
      flash[:notice] = t("document.messages.delete.success")
    rescue => e
      Rails.logger.error "[DocumentsController] destroy action failed : #{e.message}"
      flash[:alert] = t("document.messages.delete.error")
    end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

  def index
    # A lier avec les types de pièces jointes une fois ajoutés
    @types_piece = ["type1", "type2", "type3", ""]
    @documents_by_type = @types_piece.map do |type|
      @projet_courant.documents.where type_piece: type
    end
  end

  private
  def assert_file_present
    if params[:fichier].blank?
      redirect_to projet_or_dossier_documents_path(@projet_courant), alert: t("document.messages.missing")
    end
  end
end
