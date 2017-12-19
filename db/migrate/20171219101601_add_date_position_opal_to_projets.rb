class AddDatePositionOpalToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :date_position_opal, :datetime
  end
end
