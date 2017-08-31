class RemoveUnusedTablesFromDemandes < ActiveRecord::Migration[4.2]
  def change
    remove_column :demandes, :devis, :boolean
    remove_column :demandes, :travaux_engages, :boolean
    remove_column :demandes, :maison_individuelle, :boolean
    remove_column :demandes, :energie, :boolean
    remove_column :demandes, :travaux_importants, :boolean
    remove_column :demandes, :isolation, :boolean
    remove_column :demandes, :autres_besoins, :string
    remove_column :demandes, :mauvais_etat, :boolean
  end
end
