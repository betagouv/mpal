class AddDemandeurToOccupants < ActiveRecord::Migration[4.2]
  def change
    add_column :occupants, :demandeur, :boolean
  end
end
