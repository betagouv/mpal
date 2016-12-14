class AddResteAChargeToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :reste_a_charge, :float
  end
end
