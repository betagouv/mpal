class AddAnneeConstructionColumnToProjets < ActiveRecord::Migration
  def change
    add_column :projets, :annee_construction, :integer, default: 1900
  end
end
