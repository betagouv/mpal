class Occupant < ActiveRecord::Base

  enum civilite: ['mr', 'mme']
  enum lien_demandeur: [ 'père/mère', 'enfant', 'frère/soeur', 'conjoint']

  belongs_to :projet
  has_many :avis_impositions

  validates :nom, :prenom, :date_de_naissance, presence: true

  strip_fields :nom, :prenom

  scope :sans_revenus, -> { where(revenus: nil) }

  def fullname
    "#{prenom} #{nom}"
  end
end
