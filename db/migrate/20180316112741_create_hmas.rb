class CreateHmas < ActiveRecord::Migration[4.2]
  def change
    create_table :hmas do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.decimal :devis_ht, precision: 10, scale: 2
      t.decimal :devis_ttc, precision: 10, scale: 2
      t.decimal :moa, precision: 10, scale: 2
      t.boolean :other_aids, default: false, null: false
      t.decimal :other_aids_amount, precision: 10, scale: 2
      t.string :ptz

      t.timestamps
    end
  end
end
