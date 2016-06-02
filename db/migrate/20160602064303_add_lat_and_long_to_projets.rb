class AddLatAndLongToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :latitude, :float
    add_column :projets, :longitude, :float
  end
end
