class Theme < ActiveRecord::Base
  has_many :prestations

  scope :ordered, -> { order("themes.libelle, themes.id") }

  def name
    self.libelle
  end
end
