class AvisImposition < ActiveRecord::Base
  belongs_to :projet
  has_many :occupants, -> { order "id" }, dependent: :destroy

  validates :numero_fiscal, :reference_avis, :annee, presence: true
  validates :numero_fiscal, uniqueness: { scope: :projet_id, case_sensitive: false }

  def revenu_fiscal_reference
    contribuable = ApiParticulier.new(self.numero_fiscal, self.reference_avis).retrouve_contribuable
    contribuable ? contribuable.revenu_fiscal_reference : 0
  end
end
