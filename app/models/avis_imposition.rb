class AvisImposition < ActiveRecord::Base

  belongs_to :occupant

  validates :numero_fiscal, :reference_avis, :annee, :revenu_fiscal_reference, presence: true

end
