class AddNbTotalOccupant < ActiveRecord::Migration
  def change
    add_column :projets, :nb_total_occupants, :integer
  end
end
