class AddTypeLogementToDemandes < ActiveRecord::Migration[5.1]
  def change
    add_column :demandes, :type_logement, :boolean
  end
end
