class CreatePrestations < ActiveRecord::Migration[4.2]
  def change
    create_table :prestations do |t|
      t.string :libelle
      t.string :entreprise
      t.float :montant
      t.boolean :recevable
      t.belongs_to :projet, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
