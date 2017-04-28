class AddActiveToAides < ActiveRecord::Migration
  def change
    add_column :aides, :active, :boolean, null: false, default: true
  end
end
