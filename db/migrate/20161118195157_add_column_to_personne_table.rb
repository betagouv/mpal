class AddColumnToPersonneTable < ActiveRecord::Migration
  def change
    add_column :personnes, :civilite, :string
  end
end
