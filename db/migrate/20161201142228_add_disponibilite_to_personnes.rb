class AddDisponibiliteToPersonnes < ActiveRecord::Migration[4.2]
  def change
    add_column :personnes, :disponibilite, :string
  end
end
