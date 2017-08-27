class RemoveTypeAideIdToAides < ActiveRecord::Migration[4.2]
  def change
    remove_column :aides, :type_aide_id
  end
end
