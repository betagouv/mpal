class AddDevisRgeToDemandes < ActiveRecord::Migration[5.1]
  def change
    add_column :demandes, :devis_rge, :boolean
  end
end
