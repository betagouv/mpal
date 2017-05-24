class RenameTablePrestationsProjetsToPrestationChoices < ActiveRecord::Migration
  def change
    rename_table  :prestations_projets, :prestation_choices
  end
end
