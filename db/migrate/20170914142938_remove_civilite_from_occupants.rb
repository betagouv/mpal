class RemoveCiviliteFromOccupants < ActiveRecord::Migration[5.1]
  def up
    remove_column :occupants, :civilite
  end

  def down
    add_column :ocuupants, :civilite, :integer, null: true
  end
end
