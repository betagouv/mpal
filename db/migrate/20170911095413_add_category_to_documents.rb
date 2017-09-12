class AddCategoryToDocuments < ActiveRecord::Migration[5.1]
  def up
    add_reference :documents, :category, polymorphic: true, index: true

    Document.find_each do |document|
      document.update!(category_id: document.projet.id, category_type: "Projet") if document.projet_id.present?
    end

    remove_reference :documents, :projet
  end

  def down
    add_reference :documents, :projet, index: true

    Document.find_each do |document|
      if document.category_type == "Projet"
        document.update!(category_id: document.projet.id, category_type: "Projet")
      elsif document.category_type == "Payment"
        projet = document.category.try(:payment_registry).try(:projet)
        document.update!(category_id: projet.id, category_type: "Projet") if projet.present?
      end
    end

    remove_reference :documents, :category, polymorphic: true, index: true
  end
end
