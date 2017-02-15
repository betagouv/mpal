class DropNtrReferences < ActiveRecord::Migration
  def change
    drop_table :ntr_references
  end
end
