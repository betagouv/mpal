class ChangePaymentsDependencies < ActiveRecord::Migration[5.1]
  def change
    add_reference :payments, :projet, index: true
  end
end
