class AddAutreToDemandes < ActiveRecord::Migration
  def change
    add_column :demandes, :autre, :boolean
  end
end
