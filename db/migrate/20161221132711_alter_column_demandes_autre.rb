class AlterColumnDemandesAutre < ActiveRecord::Migration[4.2]
  def change
    change_table :demandes do |t|
      t.change :autre, :text
    end
  end
end
