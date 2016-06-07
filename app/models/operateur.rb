class Operateur < ActiveRecord::Base
  validates :raison_sociale, presence: true

  def self.pour_departement(departement)
    Operateur.where("'#{departement}' = ANY (departements)")
  end
end
