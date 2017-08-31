class AddAdresseARenoverToProjet < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :projets, :adresse_a_renover, index: true
    add_foreign_key :projets, :adresses, column: :adresse_a_renover_id, dependent: :nullify
  end
end
