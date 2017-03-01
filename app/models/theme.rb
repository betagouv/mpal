class Theme < ActiveRecord::Base
  validates :libelle, presence: true

  has_many :prestations

  scope :ordered, -> { order("themes.libelle, themes.id") }

  alias_attribute :name, :libelle
end
