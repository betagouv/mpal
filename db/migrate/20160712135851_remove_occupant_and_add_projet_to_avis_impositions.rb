class RemoveOccupantAndAddProjetToAvisImpositions < ActiveRecord::Migration[4.2]
  def change
    remove_reference :avis_impositions, :occupant,    index: true, foreign_key: true
    add_reference    :avis_impositions, :projet,      index: true, foreign_key: true
    add_column       :avis_impositions, :declarant_1, :string
    add_column       :avis_impositions, :declarant_2, :string
    add_column       :avis_impositions, :nombre_personnes_charge, :integer
  end
end
