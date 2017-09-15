class CreateInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :invitations do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.belongs_to :operateur, index: true, foreign_key: true
      t.string :token, index: true
    end
  end
end
