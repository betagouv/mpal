class Intervenant < ActiveRecord::Base

  has_many :commentaires, as: :auteur
  has_many :invitations
  has_many :projets, through: :invitations
  validates :raison_sociale, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  scope :pour_departement, ->(departement) { where("'#{departement}' = ANY (departements)") }
  scope :pour_role, ->(role) { where("'#{role}' = ANY (roles)") }
  scope :instructeur, -> { where("'instructeur' = ANY (roles)") }

  def self.instructeur_pour(projet)
    instructeur.pour_departement(projet.departement).limit(1).first
  end

  def to_s
    self.raison_sociale
  end

  def operateur?
    self.roles && self.roles.include?('operateur')
  end
end
