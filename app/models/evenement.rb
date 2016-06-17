class Evenement < ActiveRecord::Base
  belongs_to :projet
  belongs_to :operateur
  validates :projet, :label, :quand, presence: true
end
