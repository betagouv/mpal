class AvisImposition < ActiveRecord::Base

  belongs_to :projet

  validates :numero_fiscal, :reference_avis, :annee, presence: true

  def label
    declarants = declarant_1
    declarants << " - #{declarant_2}" if declarant_2
    "#{annee}: #{declarants} (+ #{nombre_personnes_charge} à charge)"
  end
end
