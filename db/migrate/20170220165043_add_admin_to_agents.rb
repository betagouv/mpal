class AddAdminToAgents < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :admin, :boolean, null: false, default: false
  end
end
