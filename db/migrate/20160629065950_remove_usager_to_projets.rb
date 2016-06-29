class RemoveUsagerToProjets < ActiveRecord::Migration
  def change
    remove_column :projets, :usager, :string
  end
end
