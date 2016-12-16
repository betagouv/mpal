class CreateEngagements < ActiveRecord::Migration
  def change
    create_table :engagements do |t|
      t.string :nom
      t.boolean :valeur

      t.timestamps null: false
    end
  end
end
