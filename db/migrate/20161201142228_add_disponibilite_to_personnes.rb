class AddDisponibiliteToPersonnes < ActiveRecord::Migration
  def change
    add_column :personnes, :disponibilite, :string
  end
end
