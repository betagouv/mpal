class AddAmountFieldsToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :amo_amount, :decimal, precision: 10, scale: 2
    add_column :projets, :maitrise_oeuvre_amount, :decimal, precision: 10, scale: 2
    add_column :projets, :assiette_subventionnable_amount, :decimal, precision: 10, scale: 2
  end
end
