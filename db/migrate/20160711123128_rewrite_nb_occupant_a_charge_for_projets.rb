class RewriteNbOccupantAChargeForProjets < ActiveRecord::Migration
  def change
    remove_column :projets, :nb_total_occupants, :integer
    add_column :projets, :nb_occupants_a_charge, :integer
  end
end
