class AddDefaultValueForNbOccupantsAChargeOnProjets < ActiveRecord::Migration
  def change
    change_column :projets, :nb_occupants_a_charge, :integer, default: 0
  end
end
