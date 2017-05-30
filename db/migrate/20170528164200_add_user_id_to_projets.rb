class AddUserIdToProjets < ActiveRecord::Migration
  def change
    add_reference :projets, :user, index: true, foreign_key: true
  end
end

