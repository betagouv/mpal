class DocumentsController < ApplicationController
  before_action :assert_projet_courant
  before_action :assert_file_present, only: :create
  load_and_authorize_resource

  def index
    @document_blocks = document_blocks
    @page_heading = "Pièces jointes"
  end

  def create
    begin
      if params[:payment_id].present?
        if @projet_courant.payment_registry.present?
          category = @projet_courant.payment_registry.payments.where(id: params[:payment_id]).first
          return redirect_to projet_or_dossier_documents_path(@projet_courant), alert: t("document.messages.create.error") if category.blank?
        else
          return redirect_to projet_or_dossier_documents_path(@projet_courant), alert: t("document.messages.create.error")
        end
      else
        category = @projet_courant
      end
      @document = Document.create! fichier: params[:fichier], type_piece: params[:type_piece], category: category
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
      @document = Document.find params[:id]
      @document.destroy!
      flash[:notice] = t("document.messages.delete.success")
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

  def document_blocks
    blocks = [{
      title: "Projet",
      groups: document_groups(:projet, @projet_courant),
    }]
    if @projet_courant.payment_registry.present?
      @projet_courant.payment_registry.payments.each do |payment|
        blocks << {
          title: payment.description,
          payment_id: payment.id,
          groups: document_groups(:payment, payment),
        }
      end
    end

    blocks
  end

  def document_groups(category_type, category)
    groups = []

    if category_type == :projet
      document_hash = Document.for_projet(category)
    elsif category_type == :payment
      document_hash = Document.for_payment(category)
    else
      document_hash = {}
    end

    document_hash.each_pair do |condition, types|
      if types.first.is_a? Array
        types.each { |types_from_array| groups << document_group(category, condition, types_from_array) }
      else
        groups << document_group(category, condition, types)
      end
    end
    groups
  end

  def document_group(category, condition, types)
    group = {
      condition: condition,
      elements: types.map do |type|
        {
          type: type,
          documents: category.documents.where(type_piece: type.to_s),
        }
      end
    }
    annotate_missing_elements(group)
  end

  def annotate_missing_elements(group)
    if group[:condition] == :one_of
      if group[:elements].map { |element| element[:documents].blank? }.all?
        group[:elements].each { |element| element[:missing] = true }
      else
        group[:elements].each { |element| element[:missing] = false }
      end
    else
      group[:elements].each { |element| element[:missing] = element[:documents].blank? }
    end

    group
  end
end

