class CreatePjnotes < ActiveRecord::Migration[5.1]
  def change
    create_table :pjnotes do |t|
      t.belongs_to :document, index: true, foreign_key: true
      t.belongs_to :projet, index: true, foreign_key: true
      t.belongs_to :intervenant, index: true, foreign_key: true
      t.text :notecontent
      t.integer :document_id
      t.integer :projet_id
      t.integer :intervenant_id
      t.datetime :last_read_messages_at

      t.timestamps
    end
  end
end
