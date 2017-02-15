class DropCadReferences < ActiveRecord::Migration
  def change
    drop_table :cad_references
  end
end
