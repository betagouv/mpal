class CreateOperations < ActiveRecord::Migration[4.2]
  def change
    create_table :operations do |t|
      t.string :name,      :null => false, default: ''
      t.string :code_opal, :null => false, default: ''

      t.timestamps
    end
  end
end
