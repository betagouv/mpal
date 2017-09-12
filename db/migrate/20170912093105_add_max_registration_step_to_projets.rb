class AddMaxRegistrationStepToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :max_registration_step, :integer, default: 1, null: false
  end
end
