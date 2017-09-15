class CreateCommentaires < ActiveRecord::Migration[4.2]
  def change
    create_table :commentaires do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.references :auteur, polymorphic: true, index: true
      t.text :corps_message

      t.timestamps null: false
    end
  end
end
