class CreateCadReferences < ActiveRecord::Migration
  def change
    create_table :cad_references do |t|
      t.integer :opal_id
      t.string :code
      t.text :libelle
    end
  end
end
