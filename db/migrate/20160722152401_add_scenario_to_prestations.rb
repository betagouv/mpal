class AddScenarioToPrestations < ActiveRecord::Migration
  def change
    add_column :prestations, :scenario, :string
  end
end
