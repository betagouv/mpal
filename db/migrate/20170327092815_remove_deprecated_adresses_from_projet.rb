class RemoveDeprecatedAdressesFromProjet < ActiveRecord::Migration[4.2]
  def change
    remove_column :projets, :latitude, :float
    remove_column :projets, :longitude, :float
    remove_column :projets, :adresse_ligne1, :string
    remove_column :projets, :code_postal, :string
    remove_column :projets, :code_insee, :string
    remove_column :projets, :ville, :string
    remove_column :projets, :departement, :string
    remove_column :projets, :adresse_postale_ligne1, :string
    remove_column :projets, :adresse_postale_code_postal, :string
    remove_column :projets, :adresse_postale_ville, :string
  end
end
