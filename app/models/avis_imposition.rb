class AvisImposition < ActiveRecord::Base
  belongs_to :projet
  has_many :occupants, -> { order "id" }, dependent: :destroy

  validates :numero_fiscal, :reference_avis, :annee, presence: true
  validates :numero_fiscal, uniqueness: { scope: :projet_id, case_sensitive: false }

  def is_valid_for_current_year?
    annee.to_i >= 2.years.ago.year
  end
end
