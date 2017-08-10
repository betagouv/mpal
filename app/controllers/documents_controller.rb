class DocumentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  before_action :assert_file_present, only: :create
  load_and_authorize_resource

  rescue_from do |exception|
    flash[:alert] = exception.message
    redirect_to projet_or_dossier_documents_path @projet_courant, alert: t("document.messages.error")
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to "/404"
  end

  def create
    @document = Document.create! fichier: params[:fichier], type_piece: params[:type_piece], projet: @projet_courant
    redirect_to projet_or_dossier_documents_path(@projet_courant), notice: t("document.messages.success")
  end

  def destroy
    @document = @projet_courant.documents.find params[:id]
    @document.destroy!
    redirect_to projet_or_dossier_documents_path(@projet_courant), notice: t("document.messages.delete")
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
