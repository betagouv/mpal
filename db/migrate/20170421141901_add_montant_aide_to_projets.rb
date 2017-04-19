class AddMontantAideToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :montant_aide, :decimal, precision: 10, scale: 6
  end
end
