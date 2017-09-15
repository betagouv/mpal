class AddRevenuToOccupants < ActiveRecord::Migration[4.2]
  def change
    add_column :occupants, :revenu, :integer
  end
end
