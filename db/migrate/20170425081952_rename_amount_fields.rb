class RenameAmountFields < ActiveRecord::Migration
  def change
    rename_column :projets, :montant_travaux_ht, :travaux_ht_amount
    rename_column :projets, :montant_travaux_ttc, :travaux_ttc_amount
    rename_column :projets, :reste_a_charge, :personal_funding_amount
    rename_column :projets, :pret_bancaire, :loan_amount
    rename_column :projet_aides, :montant, :amount
  end
end
