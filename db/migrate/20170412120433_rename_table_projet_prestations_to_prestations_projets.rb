class RenameTableProjetPrestationsToPrestationsProjets < ActiveRecord::Migration
  def change
    rename_table  :projet_prestations, :prestations_projets
  end
end
