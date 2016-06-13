class AddEmailToOperateurs < ActiveRecord::Migration
  def change
    add_column :operateurs, :email, :string
  end
end
