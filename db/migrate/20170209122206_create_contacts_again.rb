class CreateContactsAgain < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name,    limit: 128, null: false, default: ''
      t.string :email,   limit:  80, null: false, default: ''
      t.string :phone,   limit:  20, null: false, default: ''
      t.string :subject, limit:  80, null: false, default: ''
      t.text   :description
      t.timestamps
    end

    add_index :contacts, [:name, :email]
  end
end
