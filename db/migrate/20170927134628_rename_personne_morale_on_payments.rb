class RenamePersonneMoraleOnPayments < ActiveRecord::Migration[5.1]
  def change
    rename_column :payments, :personne_morale, :procuration
  end
end
