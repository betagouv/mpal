class RemoveThemeIdFromPrestations < ActiveRecord::Migration[4.2]
  def change
    remove_column :prestations, :theme_id
  end
end
