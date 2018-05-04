class ProjetCopro < ApplicationRecord

	belongs_to :adresse
	belongs_to :copro_info

	def display
		"#{registration_step}"
	end

end
