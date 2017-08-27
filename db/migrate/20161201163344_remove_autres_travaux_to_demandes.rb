class RemoveAutresTravauxToDemandes < ActiveRecord::Migration[4.2]
  def change
    remove_column :demandes, :autres_travaux
  end
end
