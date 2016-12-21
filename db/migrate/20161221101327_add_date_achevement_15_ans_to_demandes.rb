class AddDateAchevement15AnsToDemandes < ActiveRecord::Migration
  def change
    add_column :demandes, :date_achevement_15_ans, :boolean
  end
end
