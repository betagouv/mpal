class Projet < ActiveRecord::Base
  validates :usager, :numero_fiscal, :reference_avis, :adresse, presence: true
end
