class AddAvisImpositionIdToOccupants < ActiveRecord::Migration
  def change
    add_column :occupants, :avis_imposition_id, :integer, index: true

    # Peuple `occupant.avis_imposition_id`
    Projet.find_each do |projet|
      avis_imposition_id = projet.avis_impositions.first.id rescue nil
      projet.occupants.each do |occupant|
        occupant.update_attribute(:avis_imposition_id, avis_imposition_id)
      end
      avis = projet.avis_impositions.first
    end

    # `numero_fiscal` et `reference_avis` ont été ajouté au format JSON,
    # purge du cache pour éviter des effets de bord.
    Rails.cache.clear
  end
end
