class RemoveStateFromProjetPrestations < ActiveRecord::Migration
  def up
    remove_column :projet_prestations, :souhaite,  :boolean
    remove_column :projet_prestations, :preconise, :boolean
    remove_column :projet_prestations, :retenu,    :boolean
  end

  def down
    add_column :projet_prestations, :souhaite,  :boolean, null: false, default: false
    add_column :projet_prestations, :preconise, :boolean, null: false, default: false
    add_column :projet_prestations, :retenu,    :boolean, null: false, default: false
  end
end
