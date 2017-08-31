class CreateSuggestedOperateurs < ActiveRecord::Migration[4.2]
  def change
    create_table :suggested_operateurs, id: false do |t|
      t.integer :projet_id
      t.integer :intervenant_id
    end

    add_index :suggested_operateurs, :projet_id
    add_index :suggested_operateurs, :intervenant_id
  end
end
