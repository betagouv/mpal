class RemoveAnneeConstructionFromProjets < ActiveRecord::Migration
  def up
    Projet.find_each do |projet|
      demande = projet.demande
      next unless demande
      if projet.annee_construction.present?
        demande.update_attribute(:annee_construction, projet.annee_construction)
      end
    end
    remove_column :projets, :annee_construction
  end

  def down
    add_column :projets, :annee_construction, :integer
  end
end
