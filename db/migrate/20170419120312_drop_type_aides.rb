class DropTypeAides < ActiveRecord::Migration
  def change
    drop_table :type_aides do |t|
      t.string :libelle
    end
  end
end
