class Hma < ApplicationRecord
	  belongs_to :projet

	  validates :devis_ht, :devis_ttc, presence: true, on: :proposition_hma

	  attr_accessor :localized_global_ttc_sum, :localized_global_ht_sum, :localized_ptz
end
