class ProjetAide < ActiveRecord::Base
  include LocalizedModelConcern

  belongs_to :projet
  belongs_to :aide

  amountable :amount

  delegate :libelle, to: :aide
  validates :amount, :big_number => true
end
