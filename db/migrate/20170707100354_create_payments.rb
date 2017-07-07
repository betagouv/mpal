class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :payment_registry, index: true

      t.integer  :statut,          null: false, default: 0
      t.integer  :type_paiement
      t.string   :beneficiaire,    null: false, default: ''
      t.boolean  :personne_morale, null: false, default: false
      t.decimal  :montant,         precision: 10, scale: 2

      t.datetime :submitted_at
      t.datetime :payed_at
      t.timestamps null: false
    end
  end
end
