class AddInfosSupplementairesToDemandes < ActiveRecord::Migration[4.2]
  def change
    add_column :demandes, :complement, :text
  end
end
