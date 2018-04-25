class PjnotesController < ApplicationController
  
  before_action :assert_projet_courant
  load_and_authorize_resource

  # attr_accessor :projet_id, :document_id, :intervenant_id, :notecontent

  def index
    Rails.logger.debug("DUDEST")
  end

  def create
  	@projet_courant = Projet.find_by_locator(params[:projet_id])
    # begin
      if params[:pjnote]["notecontent"] != ""
	      @pjnote = Pjnote.create! document_id: params[:document_id], projet_id: params[:projet_id], intervenant_id: params[:intervenant_id], notecontent: params[:pjnote]["notecontent"]
	      flash[:notice] = t("document.pjnote.commentaire_enregistre")

	    end
    # rescue => e
      # Rails.logger.error "[DocumentsController] create action failed : #{e.message}"
      # if e.class == ActiveRecord::RecordInvalid
        # flash[:alert] = e.record.errors[:base].first || e.record.errors[:fichier].first
      # else
        # flash[:alert] = t("document.messages.create.error")
      # end
    # end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

  def destroy
    begin
      @pjnote = Pjnote.find params[:id]
      @projet_courant = Projet.find_by_locator(@pjnote.projet_id)
      @pjnote.destroy!
      flash[:notice] = t("document.pjnote.commenaitre_supprime")
    rescue => e
      Rails.logger.error "[PjnotesController] destroy action failed : #{e.message}"
      flash[:alert] = t("document.pjnote.commenaitre_non_supprime")
    end
    redirect_to projet_or_dossier_documents_path(@projet_courant)
  end

  def edit
  	@aNote = Pjnote.find params[:id]
  	@document = Document.find @aNote.document_id
  	@projet_courant = Projet.find @aNote.projet_id
	render "edit"
  end

  def update
    @pjnote = Pjnote.find params[:note_id]
  	@pjnote.update_attribute(:notecontent, params[:pjnote]["notecontent"])

  	@projet_courant = Projet.find_by_locator(params[:projet_id])
  	redirect_to projet_or_dossier_documents_path(@projet_courant)
  end


  # private
  def pjnote_params
    params.permit(:document_id, :projet_id, :intervenant_id, :pjnote)
  end

end
