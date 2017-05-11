class RemoveTypeAideIdToAides < ActiveRecord::Migration
  def change
    remove_column :aides, :type_aide_id
  end
end
