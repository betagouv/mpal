class RenameCommentairesToMessages < ActiveRecord::Migration[4.2]
  def change
    rename_table :commentaires, :messages
  end
end

