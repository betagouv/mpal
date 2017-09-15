class AddUserIdToProjets < ActiveRecord::Migration[4.2]
  def change
    add_reference :projets, :user, index: true, foreign_key: true
  end
end

