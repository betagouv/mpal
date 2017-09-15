class AddTimestampsToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_timestamps(:invitations)
  end
end
