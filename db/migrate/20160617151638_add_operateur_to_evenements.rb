class AddOperateurToEvenements < ActiveRecord::Migration
  def change
    add_reference :evenements, :operateur, index: true, foreign_key: true
  end
end
