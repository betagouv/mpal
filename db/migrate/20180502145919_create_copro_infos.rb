class CreateCoproInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :copro_infos do |t|

      t.belongs_to :projet_copros, index: true, foreign_key: true

      t.boolean :travaux_partie_commune, :default => false
      t.boolean :batiment_anciennete, :default => false
      t.integer :date_construction
      t.boolean :pourcentage_habitation, :default => false
      t.boolean :administration_provisoire, :default => false
      t.boolean :arrete_insalubrite, :default => false
      t.boolean :arrete_peril, :default => false
      t.boolean :arrete_securite_equipement, :default => false
      t.boolean :risque_saturnisme_plomb, :default => false
      t.integer :travaux_copro
      t.boolean :reduction_conso_energie, :default => false
      t.boolean :classification_energetique, :default => true
      t.integer :taux_charges_impayees, :default => 0
      t.boolean :perimetre_operation_programmee, :default => false
      t.boolean :travaux_deja_commence, :default => false

      t.timestamps
    end
  end
end
