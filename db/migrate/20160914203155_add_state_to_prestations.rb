class AddStateToPrestations < ActiveRecord::Migration
  def change
    add_column :prestations, :souhaite, :boolean, null: false, default: false
    add_column :prestations, :preconise, :boolean, null: false, default: false
    add_column :prestations, :retenu, :boolean, null: false, default: false
  end
end
