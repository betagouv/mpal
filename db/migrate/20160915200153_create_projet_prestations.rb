class CreateProjetPrestations < ActiveRecord::Migration
  def change
    create_table :projet_prestations do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.belongs_to :prestation, index: true, foreign_key: true
      t.boolean :souhaite, null: false, default: false
      t.boolean :preconise, null: false, default: false
      t.boolean :retenu, null: false, default: false
    end
  end
end
