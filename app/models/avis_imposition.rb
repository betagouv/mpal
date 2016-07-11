class AvisImposition < ActiveRecord::Base

  belongs_to :occupant

  validates :numero_fiscal, :reference_avis, :annee, presence: true

end
