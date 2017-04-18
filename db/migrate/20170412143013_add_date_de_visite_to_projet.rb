class AddDateDeVisiteToProjet < ActiveRecord::Migration
  def change
    add_column :projets, :date_de_visite, :date
  end
end
