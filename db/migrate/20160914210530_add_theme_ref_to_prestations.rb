class AddThemeRefToPrestations < ActiveRecord::Migration
  def change
    add_reference :prestations, :theme, index: true, foreign_key: true
  end
end
