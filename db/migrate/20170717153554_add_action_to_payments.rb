class AddActionToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :action, :integer, null: false, default: 0
  end
end
