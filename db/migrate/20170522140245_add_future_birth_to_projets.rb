class AddFutureBirthToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :future_birth, :boolean, default: false, null: false
  end
end
