class RemoveProjetIdFromPrestations < ActiveRecord::Migration[4.2]
  def change
    remove_column :prestations, :projet_id
  end
end
