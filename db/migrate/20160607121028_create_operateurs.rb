class CreateOperateurs < ActiveRecord::Migration[4.2]
  def change
    create_table :operateurs do |t|
      t.string :raison_sociale
      t.string :adresse_postale
      t.string :type
      t.string :themes, array: true
      t.string :departements, array: true
    end

    add_index :operateurs, :themes, using: 'gin'
    add_index :operateurs, :departements, using: 'gin'
  end
end
