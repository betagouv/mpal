class DropNtrReferences < ActiveRecord::Migration[4.2]
  def change
    drop_table :ntr_references
  end
end
