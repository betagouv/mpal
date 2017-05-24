class AddFutureBirthToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :future_birth, :boolean, default: false, null: false
  end
end
