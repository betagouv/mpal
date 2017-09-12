class AddMandatDataToInvitations < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :kind, :string, null: false, default: ""
    add_column :invitations, :revoked_at, :datetime
  end
end
