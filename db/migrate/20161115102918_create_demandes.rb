class CreateDemandes < ActiveRecord::Migration
  def change
    create_table :demandes do |t|
      t.belongs_to :projet, index: true, foreign_key: true
      t.boolean :froid
      t.boolean :energie
      t.boolean :probleme_deplacement
      t.boolean :handicap
      t.boolean :mauvais_etat
      t.string :autres_besoins
      t.boolean :changement_chauffage
      t.boolean :isolation
      t.boolean :adaptation_salle_de_bain
      t.boolean :accessibilite
      t.boolean :travaux_importants
      t.string :autres_travaux
    end
  end
end
