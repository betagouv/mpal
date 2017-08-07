class DocumentsController < ApplicationController
  layout "creation_dossier"

  before_action :assert_projet_courant
  load_and_authorize_resource

  rescue_from do |exception|
    flash[:alert] = exception.message
    redirect_to projet_or_dossier_payment_registry_path @projet_courant
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to "/404"
  end

  def create
    @document = @projet_courant.documents.build
    @document.label = params[:fichier_document]
    @document.fichier = params[:fichier_document]
    @document.save!
    redirect_to dossier_proposition_path(@projet_courant)
  end

  def destroy
    @document = @projet_courant.documents.find params[:id]
    @document.destroy!
    redirect_to dossier_documents(@projet_courant)
  end

  def index
    @documents = @projet_courant.documents
  end
end
