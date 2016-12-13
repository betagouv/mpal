class AddAutonomieToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :autonomie, :boolean
  end
end
