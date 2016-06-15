class Projet < ActiveRecord::Base
  validates :usager, :numero_fiscal, :reference_avis, :adresse, presence: true
  has_many :operateurs, through: :invitations
  has_many :invitations
end
