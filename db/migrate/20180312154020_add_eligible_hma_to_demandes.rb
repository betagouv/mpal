class AddEligibleHmaToDemandes < ActiveRecord::Migration[5.1]
  def change
    add_column :demandes, :eligible_hma, :boolean, default: false, null: false
    add_column :demandes, :seul, :boolean, default: false, null: false
  end
end
