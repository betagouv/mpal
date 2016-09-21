class Intervenant < ActiveRecord::Base

  has_many :commentaires, as: :auteur
  has_many :invitations
  has_many :projets, through: :invitations
  validates :raison_sociale, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i


  def self.pour_departement(departement, role: nil)
    intervenants = Intervenant.where("'#{departement}' = ANY (departements)")
    intervenants = intervenants.where("'#{role}' = ANY (roles)") if role.present?
    intervenants
  end

  def to_s
    self.raison_sociale
  end

  def operateur?
    self.roles.include?('operateur')
  end
end
