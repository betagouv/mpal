class AddCivilityToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :civility, :string
  end
end

