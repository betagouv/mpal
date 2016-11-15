class AddAdressePostaleToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :adresse_postale_ligne1, :string
    add_column :projets, :adresse_postale_code_postal, :string
    add_column :projets, :adresse_postale_ville, :string
  end
end
