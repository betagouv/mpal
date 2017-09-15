class RemoveHandicapToDemandes < ActiveRecord::Migration[4.2]
  def change
    remove_column :demandes, :handicap
  end
end
