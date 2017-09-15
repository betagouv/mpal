class CreatePaymentRegistries < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_registries do |t|
      t.integer     :statut, null: false, default: 0
      t.references  :projet, index: true, foreign_key: true
      t.timestamps           null: false
    end
  end
end
