class RenameTablePrestationsProjetsToPrestationChoices < ActiveRecord::Migration[4.2]
  def change
    rename_table  :prestations_projets, :prestation_choices
  end
end
