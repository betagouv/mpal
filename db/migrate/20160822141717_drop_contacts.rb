class DropContacts < ActiveRecord::Migration[4.2]
  def up
    drop_table :contacts
    drop_table :contacts_projets
  end

  def down
    create_table :contacts do |t|
      t.string :nom
      t.string :role
      t.string :email
      t.timestamps null: false
    end
    create_table :contacts_projets, id: false do |t|
      t.belongs_to :projet, index: true
      t.belongs_to :contact, index: true
    end    
  end
end
