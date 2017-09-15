class AddDeclarantToOccupants < ActiveRecord::Migration[4.2]
  def change
    add_column :occupants, :declarant, :boolean, null: false, default: false
  end
end
