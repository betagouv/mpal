class RenamePositionOpalOnProjets < ActiveRecord::Migration[5.1]
  def change
    rename_column :projets, :position_opal, :opal_position
  end
end
