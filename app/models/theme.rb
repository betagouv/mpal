class Theme < ActiveRecord::Base
  has_and_belongs_to_many :projets

  validates :libelle, presence: true, uniqueness: true

  scope :ordered, -> { order("themes.libelle, themes.id") }

  alias_attribute :name, :libelle
end
