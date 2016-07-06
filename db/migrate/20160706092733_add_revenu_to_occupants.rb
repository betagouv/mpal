class AddRevenuToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :revenus, :integer
  end
end
