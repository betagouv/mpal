class AddPublicToAides < ActiveRecord::Migration
  def change
    add_column :aides, :public, :boolean, null: false, default: true
  end
end
