class DropTypeAides < ActiveRecord::Migration[4.2]
  def change
    drop_table :type_aides do |t|
      t.string :libelle
    end
  end
end
