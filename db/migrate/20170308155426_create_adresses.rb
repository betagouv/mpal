class CreateAdresses < ActiveRecord::Migration[4.2]
  def change
    create_table :adresses do |t|
      t.decimal :latitude,    null: true, precision: 10, scale: 6
      t.decimal :longitude,   null: true, precision: 10, scale: 6
      t.string  :ligne_1,     null: false
      t.string  :code_insee,  null: false
      t.string  :code_postal, null: false
      t.string  :ville,       null: false
      t.string  :departement, null: false, limit: 10
      t.timestamps            null: false
    end
  end
end
