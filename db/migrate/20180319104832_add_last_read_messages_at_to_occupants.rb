class AddLastReadMessagesAtToOccupants < ActiveRecord::Migration[5.1]
  def change
    add_column :occupants, :last_read_messages_at, :datetime
  end
end
