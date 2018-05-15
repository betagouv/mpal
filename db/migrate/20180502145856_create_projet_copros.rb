class CreateProjetCopros < ActiveRecord::Migration[5.1]
  def change
    create_table :projet_copros do |t|

      t.integer	:registration_step
      t.boolean :eligible

      t.timestamps
    end
  end
end
