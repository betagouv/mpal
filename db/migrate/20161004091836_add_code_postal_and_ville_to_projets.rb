class AddCodePostalAndVilleToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :code_postal, :string
    add_column :projets, :ville, :string
  end
end
