class AddDeclarantToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :declarant, :boolean, null: false, default: false
  end
end
