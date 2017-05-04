class Occupant < ActiveRecord::Base

  enum civilite: ['mr', 'mme']
  enum lien_demandeur: [ 'père/mère', 'enfant', 'frère/soeur', 'conjoint']

  belongs_to :avis_imposition
  delegate :projet, to: :avis_imposition

  validates :nom, :prenom, presence: true
  validates :date_de_naissance, birthday: true, presence: true
  validates :civilite, presence: true, on: :update, if: :require_civilite?

  strip_fields :nom, :prenom

  scope :declarants, -> { where(declarant: true) }
  scope :sans_revenus, -> { where(revenus: nil) }

  def require_civilite?
    projet && projet.demandeur == self
  end

  def fullname
    "#{prenom} #{nom}"
  end

  def can_be_deleted?
    !demandeur && avis_imposition.occupants.count > 1
  end
end
