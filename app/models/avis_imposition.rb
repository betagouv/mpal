class AvisImposition < ActiveRecord::Base
  belongs_to :projet
  has_many :occupants, -> { order "id" }, dependent: :destroy

  validates :numero_fiscal, :reference_avis, :annee, presence: true
  validates :numero_fiscal, uniqueness: { scope: :projet_id, case_sensitive: false }

  before_create :store_rfr
  
  def is_valid_for_current_year?
    annee.to_i >= 2.years.ago.year
  end

private
  def store_rfr
    contribuable = ApiParticulier.new(self.numero_fiscal, self.reference_avis).retrouve_contribuable
    self.revenu_fiscal_reference = contribuable ? contribuable.revenu_fiscal_reference : 0
  end
end
