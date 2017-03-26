class AvisImposition < ActiveRecord::Base
  belongs_to :projet
  has_many :occupants, dependent: :destroy

  validates :numero_fiscal, :reference_avis, :annee, presence: true
  validates :numero_fiscal, uniqueness: { scope: :projet_id, case_sensitive: false }
end
