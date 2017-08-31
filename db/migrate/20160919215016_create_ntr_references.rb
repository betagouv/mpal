class CreateNtrReferences < ActiveRecord::Migration[4.2]
  def change
    create_table :ntr_references do |t|
      t.integer :opal_id
      t.string :code
      t.text :libelle
    end
  end
end
