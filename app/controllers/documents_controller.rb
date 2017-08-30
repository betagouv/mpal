class DocumentsController < ApplicationController
  before_action :assert_projet_courant
  before_action :assert_file_present, only: :create
  load_and_authorize_resource

  def index
    # À lier avec les types de pièces jointes une fois ajoutés
    @types_piece = ["type1", "type2", "type3", ""]
    @documents_by_type = @types_piece.map do |type|
      @projet_courant.documents.where type_piece: type
    end
    @page_heading = "Pièces jointes"
  end

  def create
    begin
      @document = Document.create! fichier: params[:fichier], type_piece: params[:type_piece], projet: @projet_courant
      flash[:notice] = t("document.messages.create.success")
    rescue => e
      Rails.logger.error "[DocumentsController] create action failed : #{e.message}"
      if e.class == ActiveRecord::RecordInvalid
        flash[:alert] = e.record.errors[:base].first || e.record.errors[:fichier].first
      else
        flash[:alert] = t("document.messages.create.error")
      end
    end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

  def destroy
    begin
      @document = @projet_courant.documents.find params[:id]
      if @projet_courant.date_depot.present? && @document.created_at < @projet_courant.date_depot
        flash[:notice] = t("document.messages.delete.not_allowed")
      else
        @document.destroy!
        flash[:alert] = t("document.messages.delete.success")
      end
    rescue => e
      Rails.logger.error "[DocumentsController] destroy action failed : #{e.message}"
      flash[:alert] = t("document.messages.delete.error")
    end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

private
  def assert_file_present
    if params[:fichier].blank?
      redirect_to projet_or_dossier_documents_path(@projet_courant), alert: t("document.messages.missing")
    end
  end
end

