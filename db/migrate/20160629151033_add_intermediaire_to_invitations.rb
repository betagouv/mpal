class AddIntermediaireToInvitations < ActiveRecord::Migration
  def change
    add_reference :invitations, :intermediaire, index: true
  end
end
