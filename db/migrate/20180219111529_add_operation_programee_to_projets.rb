class AddOperationProgrameeToProjets < ActiveRecord::Migration[5.1]
  def change
    add_column :projets, :name_op, :string, default: nil
    add_column :projets, :code_opal_op, :string, default: nil
  end
end
