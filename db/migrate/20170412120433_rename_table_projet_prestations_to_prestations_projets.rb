class RenameTableProjetPrestationsToPrestationsProjets < ActiveRecord::Migration[4.2]
  def change
    rename_table  :projet_prestations, :prestations_projets
  end
end
