class AddSuggestedAndContactedToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :suggested, :boolean, null: false, default: false
    add_column :invitations, :contacted, :boolean, null: false, default: false
  end
end
