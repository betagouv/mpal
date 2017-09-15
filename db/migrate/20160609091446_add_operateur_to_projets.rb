class AddOperateurToProjets < ActiveRecord::Migration[4.2]
  def change
    add_reference :projets, :operateur, index: true, foreign_key: true
  end
end
