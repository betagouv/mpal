class CreateEvenements < ActiveRecord::Migration
  def change
    create_table :evenements do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.string :label
      t.timestamp :quand

    end
  end
end
