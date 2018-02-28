class AddTravauxToDemandes < ActiveRecord::Migration[5.1]
  def change
    add_column :demandes, :travaux_isolation_murs, :boolean
    add_column :demandes, :travaux_isolation_combles, :boolean
  end
end
