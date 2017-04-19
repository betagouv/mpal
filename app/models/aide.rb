class Aide < ActiveRecord::Base
  has_many :projet_aides
  has_many :projets, through: :projet_aides

  scope :actives,  -> { where(active: true) }
  scope :publics,  -> { where(public: true) }
  scope :privates, -> { where(public: false) }
end
