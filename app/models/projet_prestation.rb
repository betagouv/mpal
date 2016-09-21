class ProjetPrestation < ActiveRecord::Base
  belongs_to :projet
  belongs_to :prestation

  validates :prestation, uniqueness: { scope: :projet }
end
