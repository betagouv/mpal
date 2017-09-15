class AddThemeRefToPrestations < ActiveRecord::Migration[4.2]
  def change
    add_reference :prestations, :theme, index: true, foreign_key: true
  end
end
