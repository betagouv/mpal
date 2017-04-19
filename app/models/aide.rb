class Aide < ActiveRecord::Base
  has_many :projet_aides
  has_many :projets, through: :projet_aides
end
