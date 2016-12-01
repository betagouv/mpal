class AddDisponibiliteToPprojet < ActiveRecord::Migration
  def change
    add_column :projets, :disponibilite, :string
  end
end
