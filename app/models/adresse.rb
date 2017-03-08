class Adresse < ActiveRecord::Base
  validates :ligne_1, :code_postal, :code_insee, :ville, :departement, presence: true
end
