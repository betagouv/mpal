class Evenement < ActiveRecord::Base
  belongs_to :projet
  belongs_to :intervenant
  validates :projet, :label, :quand, presence: true
end
