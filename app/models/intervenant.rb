class Intervenant < ActiveRecord::Base
  validates :raison_sociale, presence: true

  def self.pour_departement(departement)
    Intervenant.where("'#{departement}' = ANY (departements)")
  end
end
