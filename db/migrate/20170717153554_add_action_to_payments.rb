class AddActionToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :action, :integer, null: false, default: 0
  end
end
