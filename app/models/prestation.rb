class Prestation < ActiveRecord::Base
  has_many :prestation_choices
  has_many :projets, through: :prestation_choices

  scope :active, -> { where(active: true) }
  scope :active_for_projet, -> (projet) {
    where('active = true OR (SELECT COUNT(*) FROM prestation_choices WHERE prestation_choices.prestation_id = prestations.id AND prestation_choices.projet_id = ?) > 0', projet.id)
  }

  validates_uniqueness_of :libelle
end
