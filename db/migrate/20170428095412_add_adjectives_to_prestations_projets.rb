class AddAdjectivesToPrestationsProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :prestations_projets, :desired,     :boolean, null: false, default: false
    add_column :prestations_projets, :recommended, :boolean, null: false, default: false
    add_column :prestations_projets, :selected,    :boolean, null: false, default: false
  end
end
