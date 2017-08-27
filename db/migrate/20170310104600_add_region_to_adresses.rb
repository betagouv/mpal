class AddRegionToAdresses < ActiveRecord::Migration[4.2]
  def change
    add_column :adresses, :region, :string, null: false, default: ''
  end
end
