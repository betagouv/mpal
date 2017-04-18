class RemoveThemeIdFromPrestations < ActiveRecord::Migration
  def change
    remove_column :prestations, :theme_id
  end
end
