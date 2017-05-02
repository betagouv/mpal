class AddConsommationToProjet < ActiveRecord::Migration
  def change
    add_column :projets, :consommation_avant_travaux, :integer
    add_column :projets, :consommation_apres_travaux, :integer
  end
end
