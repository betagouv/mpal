class Projet < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  validates :usager, :numero_fiscal, :reference_avis, presence: true
end
