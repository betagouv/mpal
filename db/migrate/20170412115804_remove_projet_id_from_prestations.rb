class RemoveProjetIdFromPrestations < ActiveRecord::Migration
  def change
    remove_column :prestations, :projet_id
  end
end
