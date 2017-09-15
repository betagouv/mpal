class ChangeAmountFieldsToDecimals < ActiveRecord::Migration[4.2]
  def up
    change_column :projets, :montant_travaux_ht, :decimal, precision: 10, scale: 2
    change_column :projets, :montant_travaux_ttc, :decimal, precision: 10, scale: 2
    change_column :projets, :reste_a_charge, :decimal, precision: 10, scale: 2
    change_column :projets, :pret_bancaire, :decimal, precision: 10, scale: 2
    change_column :prestations, :montant, :decimal, precision: 10, scale: 2
    change_column :projet_aides, :montant, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :projet_aides, :montant, :float
    change_column :prestations, :montant, :float
    change_column :projets, :pret_bancaire, :float
    change_column :projets, :reste_a_charge, :float
    change_column :projets, :montant_travaux_ttc, :float
    change_column :projets, :montant_travaux_ht, :float
  end
end
