class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :libelle,   :null => false, default: ''
      t.string :code_opal, :null => false, default: ''

      t.timestamps
    end
  end
end
