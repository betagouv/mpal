class AddRolesAndRemoveTypeToIntervenants < ActiveRecord::Migration[4.2]
  def change
    add_column :intervenants, :roles, :string, array: true
    add_index :intervenants, :roles, using: 'gin'
    remove_column :intervenants, :type
  end
end
