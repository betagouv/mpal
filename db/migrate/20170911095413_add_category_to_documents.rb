class AddCategoryToDocuments < ActiveRecord::Migration[5.1]
  def up
    add_reference :documents, :category, polymorphic: true, index: true

    Document.find_each do |document|
      if document.projet_id.present?
        document.category_type = "Projet"
        document.category_id = document.projet_id
        document.save(validate: false)
      end
    end

    remove_reference :documents, :projet
  end

  def down
    add_reference :documents, :projet, index: true

    Document.find_each do |document|
      if document.category_type == "Projet"
        document.projet_id = document.category_id
      elsif document.category_type == "Payment"
        payment = Payment.find_by_id document.category_id
        if payment.present?
          payment_registry = PaymentRegistry.find_by_id payment.payment_registry_id
          if payment_registry.present? && payment_registry.projet_id.present?
            document.projet_id = payment_registry.projet_id
          end
        end
      end
      document.save(validate: false)
    end

    remove_reference :documents, :category, polymorphic: true, index: true
  end
end
