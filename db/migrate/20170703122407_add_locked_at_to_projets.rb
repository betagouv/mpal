class AddLockedAtToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :locked_at, :timestamp
  end
end
