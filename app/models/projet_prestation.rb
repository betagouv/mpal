class ProjetPrestation < ActiveRecord::Base
  belongs_to :projet
  belongs_to :prestation

  validates :prestation, uniqueness: { scope: :projet }
  scope :preconise, -> { where(preconise: true) }
end
