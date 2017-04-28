class Aide < ActiveRecord::Base
  has_many :projet_aides
  has_many :projets, through: :projet_aides

  scope :active, -> { where(active: true) }
  scope :public_assistance,    -> { where(public: true) }
  scope :not_public_assistance, -> { where(public: false) }
end
