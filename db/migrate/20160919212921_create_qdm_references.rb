class CreateQdmReferences < ActiveRecord::Migration[4.2]
  def change
    create_table :qdm_references do |t|
      t.integer :opal_id
      t.string :code
      t.text :libelle
    end
  end
end
