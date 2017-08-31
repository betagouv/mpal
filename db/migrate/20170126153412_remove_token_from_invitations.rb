class RemoveTokenFromInvitations < ActiveRecord::Migration[4.2]
  def change
    remove_column :invitations, :token, :string, index: true
  end
end
