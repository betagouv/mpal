class AddNbTotalOccupant < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :nb_total_occupants, :integer
  end
end
