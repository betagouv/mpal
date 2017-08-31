class CreateContactsProjetsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts_projets, id: false do |t|
      t.belongs_to :projet, index: true
      t.belongs_to :contact, index: true
    end
  end
end
