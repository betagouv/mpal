class AddDisponibiliteToPprojet < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :disponibilite, :string
  end
end
