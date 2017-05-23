class ChangeEmailOnIntervenants < ActiveRecord::Migration
  def change
    change_column :intervenants, :email, :string, null: false
  end
end
