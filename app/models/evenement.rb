class Evenement < ActiveRecord::Base
  belongs_to :projet
  validates :projet, :label, :quand, presence: true
end
