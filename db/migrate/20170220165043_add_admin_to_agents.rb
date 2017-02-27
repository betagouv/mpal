class AddAdminToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :admin, :boolean, null: false, default: false
  end
end
