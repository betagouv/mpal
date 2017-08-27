class AddMontantAideToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :montant_aide, :decimal, precision: 10, scale: 6
  end
end
