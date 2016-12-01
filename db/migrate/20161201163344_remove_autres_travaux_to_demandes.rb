class RemoveAutresTravauxToDemandes < ActiveRecord::Migration
  def change
    remove_column :demandes, :autres_travaux
  end
end
