class RemoveProjetIdFromPersonnes < ActiveRecord::Migration
  def up
    remove_column :personnes, :projet_id
  end
end
