class AddElegibiliteToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :eligible, :integer, default: 0, null: false
  end
end
