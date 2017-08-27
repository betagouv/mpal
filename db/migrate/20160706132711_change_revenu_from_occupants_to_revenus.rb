class ChangeRevenuFromOccupantsToRevenus < ActiveRecord::Migration[4.2]
  def change
    remove_column :occupants, :revenu, :integer
    add_column :occupants, :revenus, :integer
  end
end
