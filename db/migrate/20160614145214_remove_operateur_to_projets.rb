class RemoveOperateurToProjets < ActiveRecord::Migration
  def change
    remove_reference :projets, :operateur, index: true, foreign_key: true
  end
end
