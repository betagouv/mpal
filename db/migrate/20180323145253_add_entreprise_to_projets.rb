class AddEntrepriseToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :nom_entreprise, :string
    add_column :projets, :cp_entreprise, :string
  end
end
