class Projet < ActiveRecord::Base
  belongs_to :operateur
  validates :usager, :numero_fiscal, :reference_avis, :adresse, presence: true
end
