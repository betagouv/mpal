class AddIntermediaireToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_reference :invitations, :intermediaire, index: true
  end
end
