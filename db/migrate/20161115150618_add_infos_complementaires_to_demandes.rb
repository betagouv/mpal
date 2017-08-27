class AddInfosComplementairesToDemandes < ActiveRecord::Migration[4.2]
  def change
    change_table :demandes do |t|
      t.boolean :ptz
      t.boolean :devis
      t.boolean :travaux_engages
      t.string  :annee_construction
      t.boolean :maison_individuelle
    end
  end
end
