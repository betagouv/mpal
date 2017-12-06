class AddStatutUpdatedDateToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :statut_updated_date, :datetime
  end
end
