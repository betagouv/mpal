class AddActifToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :actif, :integer, default: 1
  end
end
