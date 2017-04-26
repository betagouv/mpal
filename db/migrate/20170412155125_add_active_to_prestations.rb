class AddActiveToPrestations < ActiveRecord::Migration
  def change
    add_column :prestations, :active, :boolean, null: false, default: true
  end
end
