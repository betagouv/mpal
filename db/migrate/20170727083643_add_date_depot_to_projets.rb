class AddDateDepotToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :date_depot, :datetime
  end
end
