class Hma < ApplicationRecord
	  belongs_to :projet

	  attr_accessor :localized_global_ttc_sum, :localized_global_ht_sum, :localized_other_aids_amount, :localized_ptz
end
