class AddEmailToOperateurs < ActiveRecord::Migration[4.2]
  def change
    add_column :operateurs, :email, :string
  end
end
