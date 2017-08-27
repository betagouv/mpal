class CreateEngagements < ActiveRecord::Migration[4.2]
  def change
    create_table :engagements do |t|
      t.string :nom
      t.boolean :valeur

      t.timestamps null: false
    end
  end
end
