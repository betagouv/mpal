class AddDepartementToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :departement, :string
  end
end
