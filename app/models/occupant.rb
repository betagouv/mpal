class Occupant < ApplicationRecord
  CIVILITIES = [["Madame", "mrs"], ["Monsieur", "mr"]]

  enum lien_demandeur: [ 'père/mère', 'enfant', 'frère/soeur', 'conjoint']

  belongs_to :avis_imposition
  delegate :projet, to: :avis_imposition

  validates :nom, :prenom, presence: true, length: { :maximum => 80 }
  validates :date_de_naissance, birthday: true, presence: true, on: :user_action
  validates :civility, presence: { message: :blank_feminine }, on: :update, if: :require_civility?

  strip_fields :nom, :prenom

  scope :declarants, -> { where(declarant: true) }
  scope :sans_revenus, -> { where(revenus: nil) }

  def require_civility?
    projet && projet.demandeur == self
  end

  def fullname
    "#{prenom} #{nom}"
  end

  def can_be_deleted?
    !demandeur && avis_imposition.occupants.count > 1
  end
end

