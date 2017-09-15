class CreateContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.string :nom
      t.string :role
      t.string :email

      t.timestamps null: false
    end
  end
end
