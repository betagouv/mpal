class Prestation < ActiveRecord::Base
  has_and_belongs_to_many :projets

  scope :actives, -> { where(active: true) }

  validates_uniqueness_of :libelle
end
