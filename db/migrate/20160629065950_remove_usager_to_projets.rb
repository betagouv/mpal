class RemoveUsagerToProjets < ActiveRecord::Migration[4.2]
  def change
    remove_column :projets, :usager, :string
  end
end
