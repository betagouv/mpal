class AddInfosSupplementairesToDemandes < ActiveRecord::Migration
  def change
    add_column :demandes, :complement, :text
  end
end
