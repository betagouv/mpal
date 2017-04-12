class Theme < ActiveRecord::Base
  validates :libelle, presence: true

  has_and_belongs_to_many :projets

  scope :ordered, -> { order("themes.libelle, themes.id") }

  alias_attribute :name, :libelle
end
