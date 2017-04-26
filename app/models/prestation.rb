class Prestation < ActiveRecord::Base
  has_and_belongs_to_many :projets

  validates_uniqueness_of :libelle
end
