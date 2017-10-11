class DropPaymentRegistry < ActiveRecord::Migration[5.1]
  def change
    drop_table :payment_registries
  end
end
