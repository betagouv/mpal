class AddCivilityToOccupants < ActiveRecord::Migration[4.2]
  def change
    add_column :occupants, :civility, :string
  end
end

