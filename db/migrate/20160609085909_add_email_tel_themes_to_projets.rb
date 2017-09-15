class AddEmailTelThemesToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :email, :string
    add_column :projets, :tel, :string
    add_column :projets, :themes, :string, array: true
    add_index  :projets, :themes, using: 'gin'
  end
end
