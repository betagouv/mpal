class RemoveOperateurToProjets < ActiveRecord::Migration[4.2]
  def change
    remove_reference :projets, :operateur, index: true, foreign_key: true
  end
end
