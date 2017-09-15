class RemoveProjetIdFromPersonnes < ActiveRecord::Migration[4.2]
  def up
    Personne.all.each do |personne|
      if personne.prenom.blank? || personne.projet_id.blank?
        Projet.where(personne_id: personne.id).each do |projet|
          projet.update_attribute(:personne_id, nil)
        end
        personne.destroy!
      end
    end
    remove_column :personnes, :projet_id
  end

  def down
    add_belongs_to :personnes, :projet, index: true, foreign_key: true
  end
end
