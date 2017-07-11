class AddModifiedRevenuFiscalReferenceToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :modified_revenu_fiscal_reference, :integer
  end
end
