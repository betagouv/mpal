class ProjetAide < ActiveRecord::Base
  include LocalizedModelConcern

  belongs_to :projet
  belongs_to :aide

  amountable :amount

  delegate :libelle, to: :aide
end
