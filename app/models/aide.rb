class Aide < ActiveRecord::Base
  has_many :projet_aides
  has_many :projets, through: :projet_aides

  scope :active, -> { where(active: true) }
  scope :active_for_projet, -> (projet) {
    where('active = true OR (SELECT COUNT(*) FROM projet_aides WHERE projet_aides.aide_id = aides.id AND projet_aides.projet_id = ?) > 0', projet.id)
  }
  scope :public_assistance, -> { where(public: true) }
  scope :not_public_assistance, -> { where(public: false) }
end
