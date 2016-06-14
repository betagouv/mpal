class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.belongs_to :operateur, index: true, foreign_key: true
      t.string :token
    end
  end
end
