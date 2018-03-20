class AddPrimeHmaToDemandes < ActiveRecord::Migration[5.1]
  def change
    add_column :demandes, :prime_hma, :boolean
  end
end
