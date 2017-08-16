class RenameCommentairesToMessages < ActiveRecord::Migration
  def change
    rename_table :commentaires, :messages
  end
end

