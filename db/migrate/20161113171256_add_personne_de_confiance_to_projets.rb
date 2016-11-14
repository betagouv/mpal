class AddPersonneDeConfianceToProjets < ActiveRecord::Migration
  def change
    add_reference :projets, :personne, index: true, foreign_key: true
  end
end
