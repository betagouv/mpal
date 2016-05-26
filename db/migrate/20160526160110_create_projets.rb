class Projet < ActiveRecord::Migration
  def change
    create_table :projets do |t|
      t.string  :numero_fiscal
      t.string  :reference_avis
      t.text    :description

      t.timestamps
    end
  end
end
