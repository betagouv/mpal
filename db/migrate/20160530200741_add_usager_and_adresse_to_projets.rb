class AddUsagerAndAdresseToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :usager, :string
    add_column :projets, :adresse, :string
  end
end
