class RemoveHandicapToDemandes < ActiveRecord::Migration
  def change
    remove_column :demandes, :handicap
  end
end
