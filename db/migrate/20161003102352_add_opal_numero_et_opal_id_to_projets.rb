class AddOpalNumeroEtOpalIdToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :opal_numero, :string
    add_column :projets, :opal_id, :string
  end
end
