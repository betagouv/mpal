class AddDateDeVisiteToProjet < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :date_de_visite, :date
  end
end
