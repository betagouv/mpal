class AddElegibiliteToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :eligibilite, :integer, default: 0, null: false
  end
end
