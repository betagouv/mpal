class AddColumnToPersonneTable < ActiveRecord::Migration[4.2]
  def change
    add_column :personnes, :civilite, :string
  end
end
