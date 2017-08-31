class AddCodePostalAndVilleToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :code_postal, :string
    add_column :projets, :ville, :string
  end
end
