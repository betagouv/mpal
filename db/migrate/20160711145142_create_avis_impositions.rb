class CreateAvisImpositions < ActiveRecord::Migration[4.2]
  def change
    create_table :avis_impositions do |t|
      t.belongs_to :occupant, index: true, foreign_key: true
      t.string :numero_fiscal
      t.string :reference_avis
      t.integer :annee
      t.integer :revenu_fiscal_reference

      t.timestamps null: false
    end
    remove_column :occupants, :revenus, :integer
  end
end
