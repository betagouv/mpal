class Prestation < ActiveRecord::Base
  has_many :prestation_choices
  has_many :projets, through: :prestation_choices

  scope :active, -> { where(active: true) }

  validates_uniqueness_of :libelle

  def choice_for_projet(projet)
    self.prestation_choices.all.find_by(projet_id: projet.id)
  end
end
