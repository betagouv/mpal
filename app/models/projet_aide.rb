class ProjetAide < ActiveRecord::Base
  include LocalizedModelConcern

  belongs_to :projet
  belongs_to :aide

  amountable :amount

  delegate :libelle, to: :aide
  validates :amount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999999999 }
end
