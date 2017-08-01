class AddDateDepotToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :date_depot, :datetime
  end
end
