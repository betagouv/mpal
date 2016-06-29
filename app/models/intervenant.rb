class Intervenant < ActiveRecord::Base
  validates :raison_sociale, presence: true
  has_many :commentaires, as: :auteur

  def self.pour_departement(departement, role: nil)
    intervenants = Intervenant.where("'#{departement}' = ANY (departements)")
    intervenants = intervenants.where("'#{role}' = ANY (roles)") if role.present?
    intervenants
  end

  def to_s
    self.raison_sociale
  end
end
