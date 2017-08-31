class AddScenarioToPrestations < ActiveRecord::Migration[4.2]
  def change
    add_column :prestations, :scenario, :string
  end
end
