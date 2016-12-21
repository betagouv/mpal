class AlterColumnDemandesAutre < ActiveRecord::Migration
  def change
    change_table :demandes do |t|
      t.change :autre, :text
    end
  end
end
