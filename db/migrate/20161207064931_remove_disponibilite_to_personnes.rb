class RemoveDisponibiliteToPersonnes < ActiveRecord::Migration
  def change
    remove_column :personnes, :disponibilite
  end
end
