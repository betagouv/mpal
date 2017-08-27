class AddActiveToAides < ActiveRecord::Migration[4.2]
  def change
    add_column :aides, :active, :boolean, null: false, default: true
  end
end
