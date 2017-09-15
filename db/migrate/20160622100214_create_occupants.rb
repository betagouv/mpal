class CreateOccupants < ActiveRecord::Migration[4.2]
  def change
    create_table :occupants do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.string :nom
      t.string :prenom
      t.string :lien_demandeur
      t.date :date_de_naissance
      t.column :civilite, :integer, null: true

      t.timestamps null: false
    end
  end
end
