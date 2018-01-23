class AddOpalPositionLabelToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :opal_position_label, :string
  end
end
