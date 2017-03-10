class AddRegionToAdresses < ActiveRecord::Migration
  def change
    add_column :adresses, :region, :string, null: false, default: ''
  end
end
