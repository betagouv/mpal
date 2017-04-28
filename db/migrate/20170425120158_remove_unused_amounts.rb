class RemoveUnusedAmounts < ActiveRecord::Migration
  def change
    remove_column :prestations, :montant
    remove_column :projets, :montant_aide
  end
end
