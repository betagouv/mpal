class AddDefaultValueForNbOccupantsAChargeOnProjets < ActiveRecord::Migration[4.2]
  def change
    change_column :projets, :nb_occupants_a_charge, :integer, default: 0
  end
end
