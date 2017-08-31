class RenameOperateursToIntervenants < ActiveRecord::Migration[4.2]
  def change
    rename_table :operateurs, :intervenants
    rename_column :evenements, :operateur_id, :intervenant_id
    rename_column :invitations, :operateur_id, :intervenant_id
  end
end
