class AddPlateformeIdToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :plateforme_id, :string, index: true
  end
end
