class AddOpalNumeroEtOpalIdToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :opal_numero, :string
    add_column :projets, :opal_id, :string
  end
end
