class CreateIntervenantsOperations < ActiveRecord::Migration
  def change
    create_table :intervenants_operations do |t|
      t.references :intervenant, index: true, foreign_key: true
      t.references :operation,   index: true, foreign_key: true
    end
  end
end
