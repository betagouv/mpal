class AddManyTravauxToDemande < ActiveRecord::Migration
  def change
    add_column :demandes, :travaux_fenetres, :boolean
    add_column :demandes, :travaux_isolation, :boolean
    add_column :demandes, :travaux_chauffage, :boolean
    add_column :demandes, :travaux_adaptation_sdb, :boolean
    add_column :demandes, :travaux_monte_escalier, :boolean
    add_column :demandes, :travaux_amenagement_ext, :boolean
    add_column :demandes, :travaux_autres, :boolean
  end
end
