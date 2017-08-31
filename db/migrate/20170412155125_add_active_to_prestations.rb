class AddActiveToPrestations < ActiveRecord::Migration[4.2]
  def change
    add_column :prestations, :active, :boolean, null: false, default: true
  end
end
