class Intervenant < ActiveRecord::Base

  has_many :commentaires, as: :auteur
  # has_many :projets, through: :invitation

  validates :raison_sociale, presence: true

  def self.pour_departement(departement, role: nil)
    intervenants = Intervenant.where("'#{departement}' = ANY (departements)")
    intervenants = intervenants.where("'#{role}' = ANY (roles)") if role.present?
    intervenants
  end

  def to_s
    self.raison_sociale
  end
end
