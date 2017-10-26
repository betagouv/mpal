class RemoveProjetIdFromOccupants < ActiveRecord::Migration[5.1]
  def up
    remove_column :occupants, :projet_id
  end

  def down
    add_column    :occupants, :projet_id, :integer
  end
end

