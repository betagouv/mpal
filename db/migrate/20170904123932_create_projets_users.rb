class CreateProjetsUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :projets_users do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :projet, index: true, foreign_key: true
      t.string     :kind, null: false, default: "demandeur"
      t.timestamps null: false
      t.datetime   :revoked_at
    end
  end
end
