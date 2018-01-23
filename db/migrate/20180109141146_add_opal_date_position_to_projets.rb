class AddOpalDatePositionToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :opal_date_position, :datetime
  end
end
