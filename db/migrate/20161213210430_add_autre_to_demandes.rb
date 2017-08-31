class AddAutreToDemandes < ActiveRecord::Migration[4.2]
  def change
    add_column :demandes, :autre, :boolean
  end
end
