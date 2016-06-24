class Intervenant < ActiveRecord::Base
  validates :raison_sociale, presence: true

  def self.pour_departement(departement, role: nil)
    intervenants = Intervenant.where("'#{departement}' = ANY (departements)")
    intervenants = intervenants.where("'#{role}' = ANY (roles)") if role.present?
    intervenants
  end
end
