class CreateProjetAides < ActiveRecord::Migration
  def change
    create_table :projet_aides do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.belongs_to :aide, index: true, foreign_key: true
      t.float :montant
    end
  end
end
