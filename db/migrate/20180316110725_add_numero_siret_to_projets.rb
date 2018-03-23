class AddNumeroSiretToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :numero_siret, :string
  end
end
