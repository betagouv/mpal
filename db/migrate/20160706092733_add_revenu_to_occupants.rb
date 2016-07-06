class AddRevenuToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :revenu, :integer
  end
end
