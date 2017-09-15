class RemoveDisponibiliteToPersonnes < ActiveRecord::Migration[4.2]
  def change
    remove_column :personnes, :disponibilite
  end
end
