class ChangeEmailOnIntervenants < ActiveRecord::Migration[4.2]
  def change
    change_column :intervenants, :email, :string, null: false
  end
end
