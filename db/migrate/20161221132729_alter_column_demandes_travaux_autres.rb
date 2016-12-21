class AlterColumnDemandesTravauxAutres < ActiveRecord::Migration
  def change
    change_table :demandes do |t|
      t.change :travaux_autres, :text
    end
  end
end
