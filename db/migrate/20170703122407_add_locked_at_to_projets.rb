class AddLockedAtToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :locked_at, :timestamp
  end
end
