class AddTypePieceToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :type_piece, :string, null: false, default: ""
  end
end
