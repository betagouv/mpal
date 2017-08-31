class AddDateAchevement15AnsToDemandes < ActiveRecord::Migration[4.2]
  def change
    add_column :demandes, :date_achevement_15_ans, :boolean
  end
end
