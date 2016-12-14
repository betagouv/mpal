class AddPlateformeIdToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :plateforme_id, :string, index: true
  end
end
