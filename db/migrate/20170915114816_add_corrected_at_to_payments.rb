class AddCorrectedAtToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :corrected_at, :datetime
  end
end
