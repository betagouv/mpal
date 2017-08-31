class CreateProjets < ActiveRecord::Migration[4.2]
  def change
    create_table :projets do |t|
      t.string  :numero_fiscal
      t.string  :reference_avis
      t.text    :description

      t.timestamps
    end
  end
end
