class RemoveUnusedAmounts < ActiveRecord::Migration[4.2]
  def change
    remove_column :prestations, :montant
    remove_column :projets, :montant_aide
  end
end
