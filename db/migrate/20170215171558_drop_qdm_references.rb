class DropQdmReferences < ActiveRecord::Migration
  def change
    drop_table :qdm_references
  end
end
