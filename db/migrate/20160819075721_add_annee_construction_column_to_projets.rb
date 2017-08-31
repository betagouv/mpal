class AddAnneeConstructionColumnToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :annee_construction, :integer, default: 1900
  end
end
