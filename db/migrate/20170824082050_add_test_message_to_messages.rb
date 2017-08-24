class AddTestMessageToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :test_message, :string
  end
end
