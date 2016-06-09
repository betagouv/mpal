class AddOperateurToProjets < ActiveRecord::Migration
  def change
    add_reference :projets, :operateur, index: true, foreign_key: true
  end
end
