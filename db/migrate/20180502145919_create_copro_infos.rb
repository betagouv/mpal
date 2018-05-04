class CreateCoproInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :copro_infos do |t|

      t.belongs_to :projet_copros, index: true, foreign_key: true

      t.boolean :travaux_partie_commune, :default => false, :null => false
      t.boolean :batiment_anciennete, :default => false, :null => false
      t.integer :date_construction
      t.boolean :pourcentage_habitation, :default => false, :null => false
      t.boolean :administration_provisoire, :null => false
      t.boolean :arrete_insalubrite
      t.boolean :arrete_peril
      t.boolean :arrete_securite_equipement
      t.boolean :risque_saturnisme_plomb
      t.integer :travaux_copro, :null => false
      t.boolean :reduction_conso_energie
      t.boolean :classification_energetique, :default => false, :null => false
      t.integer :taux_charges_impayees
      t.boolean :perimetre_operation_programmee
      t.boolean :travaux_deja_commence

      t.timestamps
    end
  end
end
