class ChangeRevenuFromOccupantsToRevenus < ActiveRecord::Migration
  def change
    remove_column :occupants, :revenu, :integer
    add_column :occupants, :revenus, :integer
  end
end
