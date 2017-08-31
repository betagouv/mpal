class UpdatePersonneTableWithForeignKeyProjet < ActiveRecord::Migration[4.2]
  def change
    change_table :personnes do |t|
      t.belongs_to :projet, index: true, foreign_key: true
    end
  end
end
