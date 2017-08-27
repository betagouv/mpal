class AddAdressePostaleToProjet < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :projets, :adresse_postale, index: true
    add_foreign_key :projets, :adresses, column: :adresse_postale_id, dependent: :nullify
  end
end
