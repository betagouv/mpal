class AddDemandeurToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :demandeur, :boolean
  end
end
