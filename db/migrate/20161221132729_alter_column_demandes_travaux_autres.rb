class AlterColumnDemandesTravauxAutres < ActiveRecord::Migration[4.2]
  def change
    change_table :demandes do |t|
      t.change :travaux_autres, :text
    end
  end
end
