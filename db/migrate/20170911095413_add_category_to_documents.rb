class AddCategoryToDocuments < ActiveRecord::Migration[5.1]
  def up
    add_reference :documents, :category, polymorphic: true, index: true

    Document.find_each do |document|
      document.update!(category_id: document.projet_id, category_type: "Projet") if document.projet_id.present?
    end

    remove_reference :documents, :projet
  end

  def down
    add_reference :documents, :projet, index: true

    Document.find_each do |document|
      if document.category_type == "Projet"
        document.update! projet_id: document.category_id
      elsif document.category_type == "Payment"
        payment = Payment.find_by_id document.category_id
        if payment.present?
          payment_registry = PaymentRegistry.find_by_id payment.payment_registry_id
          if payment_registry.present? && payment_registry.projet_id.present?
            document.update! projet_id: payment_registry.projet_id
          end
        end
      end
    end

    remove_reference :documents, :category, polymorphic: true, index: true
  end
end
