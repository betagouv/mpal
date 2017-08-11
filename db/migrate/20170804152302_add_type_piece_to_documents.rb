class AddTypePieceToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :type_piece, :string, null: false, default: ""
  end
end
