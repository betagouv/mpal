class AddTimestampsToInvitations < ActiveRecord::Migration
  def change
    add_timestamps(:invitations)
  end
end
