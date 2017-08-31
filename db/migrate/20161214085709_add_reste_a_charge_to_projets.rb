class AddResteAChargeToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :reste_a_charge, :float
  end
end
