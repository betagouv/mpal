class AddAutonomieToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :autonomie, :boolean
  end
end
