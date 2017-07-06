class CreateOperationsProjets < ActiveRecord::Migration
  def change
    create_table :operations_projets do |t|
      t.references :operation, index: true, foreign_key: true
      t.references :projet,    index: true, foreign_key: true
    end
  end
end
