class AddCategoryToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_reference :documents, :category, polymorphic: true, index: true
  end
end


class AddStatutUpdateDateToProjets < ActiveRecord::Migration[5.1]
  def change
	add_column :projets, :statut_updated_date, :datetime
  end
end
