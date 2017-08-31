class AddLatAndLongToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :latitude, :float
    add_column :projets, :longitude, :float
  end
end
