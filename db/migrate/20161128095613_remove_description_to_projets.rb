class RemoveDescriptionToProjets < ActiveRecord::Migration
  def change
    remove_column :projets, :description
  end
end
