class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :libelle
    end
  end
end
