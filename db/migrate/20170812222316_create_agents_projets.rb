class CreateAgentsProjets < ActiveRecord::Migration[4.2]
  def change
    create_table :agents_projets do |t|
      t.references :agent, index: true, foreign_key: true
      t.references :projet, index: true, foreign_key: true
      t.datetime   :last_viewed_at
      t.datetime   :last_read_messages_at
      t.timestamps null: false
    end
  end
end

