class ChangeAnneeConstructionTypeOnDemandes < ActiveRecord::Migration[4.2]
  def up
    Demande.find_each do |demande|
      if demande.annee_construction.blank?
        demande.update_attribute(:annee_construction, nil)
      else
        demande.update_attribute(:annee_construction, demande.annee_construction.to_i)
      end
    end
    change_column :demandes, :annee_construction, 'integer USING CAST(annee_construction AS integer)'
  end

  def down
    change_column :demandes, :annee_construction, :string
  end
end
