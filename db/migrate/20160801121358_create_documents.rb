class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :label
      t.string :fichier
      t.belongs_to :projet, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
