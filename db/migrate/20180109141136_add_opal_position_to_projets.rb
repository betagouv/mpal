class AddOpalPositionToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :position_opal, :string
  end
end
