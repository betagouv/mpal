class DropCadReferences < ActiveRecord::Migration[4.2]
  def change
    drop_table :cad_references
  end
end
