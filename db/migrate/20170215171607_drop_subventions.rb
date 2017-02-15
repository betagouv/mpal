class DropSubventions < ActiveRecord::Migration
  def change
    drop_table :subventions
  end
end
