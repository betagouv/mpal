class DropQdmReferences < ActiveRecord::Migration[4.2]
  def change
    drop_table :qdm_references
  end
end
