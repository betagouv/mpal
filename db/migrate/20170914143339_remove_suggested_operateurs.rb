class RemoveSuggestedOperateurs < ActiveRecord::Migration[5.1]
  def up
    drop_table :suggested_operateurs
  end

  def down
    create_table :suggested_operateurs, id: false do |t|
      t.integer :projet_id
      t.integer :intervenant_id
    end

    add_index :suggested_operateurs, :projet_id
    add_index :suggested_operateurs, :intervenant_id
  end
end

