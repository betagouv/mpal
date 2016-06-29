class AddProducteurEvenementAndRemoveIntervenantToEvenements < ActiveRecord::Migration
  def change
    change_table :evenements do |t|
      t.references :producteur, polymorphic: true, index: true
    end
    remove_reference :evenements, :intervenant, index: true, foreign_key: true
  end
end
