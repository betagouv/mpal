class AddInfosToProjets < ActiveRecord::Migration[4.2]
  def change
    add_column :projets, :type_logement, :string
    add_column :projets, :etage, :string
    add_column :projets, :nb_pieces, :string
    add_column :projets, :surface_habitable, :integer
    add_column :projets, :etiquette_avant_travaux, :string
    add_column :projets, :niveau_gir, :integer
    add_column :projets, :handicap, :boolean
    add_column :projets, :demandeur_salarie, :boolean
    add_column :projets, :entreprise_plus_10_personnes, :boolean
    add_column :projets, :note_degradation, :integer
    add_column :projets, :note_insalubrite, :integer
    add_column :projets, :ventilation_adaptee, :boolean
    add_column :projets, :presence_humidite, :boolean
    add_column :projets, :auto_rehabilitation, :boolean
    add_column :projets, :remarques_diagnostic, :text
    add_column :projets, :etiquette_apres_travaux, :string
    add_column :projets, :gain_energetique, :integer
    add_column :projets, :montant_travaux_ht, :float
    add_column :projets, :montant_travaux_ttc, :float
    add_column :projets, :pret_bancaire, :float
    add_column :projets, :precisions_travaux, :text
    add_column :projets, :precisions_financement, :text
  end
end
