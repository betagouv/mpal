class AddPublicToAides < ActiveRecord::Migration[4.2]
  def change
    add_column :aides, :public, :boolean, null: false, default: true
  end
end
