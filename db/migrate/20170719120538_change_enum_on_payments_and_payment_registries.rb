class ChangeEnumOnPaymentsAndPaymentRegistries < ActiveRecord::Migration
  def up
    remove_column :payment_registries, :statut
    change_column :payments,           :statut,        :string,  null: true,  default: nil
    change_column :payments,           :action,        :string,  null: true,  default: nil
    change_column :payments,           :type_paiement, :string
  end

  def down
    remove_column :payments,           :statut
    remove_column :payments,           :action
    remove_column :payments,           :type_paiement

    add_column    :payment_registries, :statut,        :integer, null: false, default: 0
    add_column    :payments,           :statut,        :integer, null: false, default: 0
    add_column    :payments,           :action,        :integer, null: false, default: 0
    add_column    :payments,           :type_paiement, :integer
  end
end
