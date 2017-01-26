class RemoveTokenFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :token, :string, index: true
  end
end
