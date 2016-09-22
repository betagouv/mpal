class AddStatutAndOperateurToProjets < ActiveRecord::Migration
  def change
    add_column      :projets, :statut, :integer, default: 0
    add_column      :projets, :operateur_id, :integer
    add_index       :projets, :operateur_id
    add_foreign_key :projets, :intervenants, column: :operateur_id

  end
end
