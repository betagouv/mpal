class AddUsagerAndAdresseToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :usager, :string
    add_column :projets, :adresse, :string
  end
end
