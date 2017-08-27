class AddModifiedRevenuFiscalReferenceToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :modified_revenu_fiscal_reference, :integer
  end
end
