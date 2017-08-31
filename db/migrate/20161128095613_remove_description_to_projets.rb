class RemoveDescriptionToProjets < ActiveRecord::Migration[4.2]
  def change
    remove_column :projets, :description
  end
end
