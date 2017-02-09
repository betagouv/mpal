class Intervenant < ActiveRecord::Base

  has_many :commentaires, as: :auteur
  has_many :invitations
  has_many :projets, through: :invitations
  has_many :agents
  validates :raison_sociale, presence: true
  validates :email, email: true, allow_blank: true

  scope :pour_departement, ->(departement) { where("'#{departement}' = ANY (departements)") }
  scope :pour_role, ->(role) { where("'#{role}' = ANY (roles)") }
  scope :instructeur, -> { where("'instructeur' = ANY (roles)") }

  def self.instructeur_pour(projet)
    instructeur.pour_departement(projet.departement).limit(1).first
  end

  def instructeur?
    (roles || []).include?('instructeur')
  end

  def pris?
    (roles || []).include?('pris')
  end

  def operateur?
    (roles || []).include?('operateur')
  end

  def to_s
    self.raison_sociale
  end
end
